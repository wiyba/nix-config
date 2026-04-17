#!/usr/bin/env bash
# Fork of https://github.com/elitak/nixos-infect
# Trimmed to a single generic-VPS path for wiyba's flake-based setup.
#
# Usage:
#   curl -sL https://.../nixos-infect.sh | HOSTNAME=newvps bash
#
# Environment:
#   HOSTNAME      new host name (default: $(hostname -s))
#   REPO_URL      nix-config repo to clone (default: wiyba/nix-config)
#   REPO_BRANCH   branch to check out (default: main)
#   NIX_CHANNEL   nix channel to use for the bootstrap build (default: nixos-25.11)
#   SSH_KEYS      extra authorized keys (newline separated); otherwise read from authorized_keys
#   NO_REBOOT     set to skip the final reboot
#   NO_INFECT     set to skip nix install + switch (debug: only render configs)
#   NO_REPO       set to skip cloning the repo scaffold
#   NO_SWAP       set to skip temporary swap file creation

set -euo pipefail

NEW_HOST="${HOSTNAME:-$(hostname -s)}"
REPO_URL="${REPO_URL:-https://github.com/wiyba/nix-config.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
NIX_CHANNEL="${NIX_CHANNEL:-nixos-25.11}"
GEN_DIR="/etc/nixos-generated"
REPO_DIR="/root/nix-config"

# ---------- helpers ---------------------------------------------------------

log()  { printf '\n\033[1;34m[infect]\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\n\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

req() { command -v "$1" >/dev/null 2>&1; }

isEFI()    { [ -d /sys/firmware/efi ]; }
isX86_64() { [ "$(uname -m)" = x86_64 ]; }

# ---------- env checks ------------------------------------------------------

checkEnv() {
  [ "$(id -u)" -eq 0 ] || die "must run as root"

  # minimal deps — install if missing using whichever package manager is present
  local missing=()
  for b in curl bzcat xzcat tar ip awk cut groupadd useradd git; do
    req "$b" || missing+=("$b")
  done

  if [ ${#missing[@]} -gt 0 ]; then
    log "installing missing deps: ${missing[*]}"
    if   req apt-get; then apt-get update -y && apt-get install -y curl bzip2 xz-utils tar iproute2 gawk coreutils git passwd
    elif req dnf;     then dnf install -y curl bzip2 xz tar iproute gawk coreutils git shadow-utils
    elif req yum;     then yum install -y curl bzip2 xz tar iproute gawk coreutils git shadow-utils
    else die "unknown package manager — install manually: ${missing[*]}"
    fi
  fi

  # some distros ship these 0644 which breaks sshd on the NixOS side
  chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
}

# ---------- disk / boot detection ------------------------------------------

findESP() {
  local esp=""
  for d in /boot/EFI /boot/efi /boot; do
    [ -d "$d" ] || continue
    [ "$d" = "$(df "$d" --output=target | tail -n1)" ] \
      && esp="$(df "$d" --output=source | tail -n1)" \
      && break
  done
  [ -n "$esp" ] || return 1
  for uuid in /dev/disk/by-uuid/*; do
    [ "$(readlink -f "$uuid")" = "$esp" ] && { echo "$uuid"; return 0; }
  done
  echo "$esp"
}

prepareEnv() {
  if isEFI; then
    esp="$(findESP)" || die "could not find EFI System Partition"
    if   mount | grep -q /boot/efi; then bootFs=/boot/efi
    elif mount | grep -q /boot/EFI; then bootFs=/boot/EFI
    else                                 bootFs=/boot
    fi
    grubdev=""
  else
    for grubdev in /dev/vda /dev/sda /dev/xvda /dev/nvme0n1; do
      [ -e "$grubdev" ] && break
    done
    esp=""
    bootFs=""
  fi

  rootfsdev="$(mount | awk '$3=="/"{print $1; exit}')"
  rootfstype="$(df "$rootfsdev" --output=fstype | tail -n1)"

  export USER=root
  export HOME=/root
  mkdir -p -m 0755 /nix
}

# ---------- swap ------------------------------------------------------------

existingSwap() {
  local s
  s="$(swapon --show --noheadings --raw 2>/dev/null || true)"
  zramswap=true
  swapcfg=""
  if [ -n "$s" ]; then
    local dev="${s%% *}"
    if [[ "$dev" == /dev/* ]]; then
      zramswap=false
      swapcfg="swapDevices = [ { device = \"$dev\"; } ];"
      NO_SWAP=1
    fi
  fi
}

makeSwap()   { swapFile=$(mktemp /tmp/nixos-infect.XXXXX.swp); dd if=/dev/zero of="$swapFile" bs=1M count=1024 status=none; chmod 600 "$swapFile"; mkswap -q "$swapFile"; swapon "$swapFile"; }
removeSwap() { swapoff -a || true; rm -f /tmp/nixos-infect.*.swp; }

# ---------- config generation ----------------------------------------------

collectKeys() {
  local keys=""
  for p in /root/.ssh/authorized_keys "/home/${SUDO_USER:-}/.ssh/authorized_keys" "$HOME/.ssh/authorized_keys"; do
    [ -r "$p" ] || continue
    keys="$(grep -Ev '^\s*(#|$)' "$p" || true)"
    [ -n "$keys" ] && break
  done
  [ -n "${SSH_KEYS:-}" ] && keys="$keys"$'\n'"$SSH_KEYS"
  # drop CRs + trim
  printf '%s' "$keys" | tr -d '\r' | awk 'NF{print}'
}

bootCfg() {
  if isEFI; then
    cat <<EOF
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "$bootFs";
  fileSystems."$bootFs" = { device = "$esp"; fsType = "vfat"; };
EOF
  else
    cat <<EOF
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "$grubdev";
EOF
  fi
}

networkCfg() {
  local eth0_name eth0_ip4s eth0_ip6s gateway gateway6 ether0 nameservers predictable
  eth0_name="$(ip -o link show | awk -F': ' '$2 !~ /^(lo|docker|veth|br-|virbr|tun|tap)/{print $2; exit}')"
  [ -n "$eth0_name" ] || { warn "no network interface detected — skipping networking.nix"; return 1; }

  eth0_ip4s="$(ip -4 addr show dev "$eth0_name" | awk '/inet /{print $2}' | sed -E 's|([0-9.]+)/([0-9]+)|{ address="\1"; prefixLength=\2; }|')"
  eth0_ip6s="$(ip -6 addr show dev "$eth0_name" scope global | awk '/inet6 /{print $2}' | sed -E 's|([0-9a-f:]+)/([0-9]+)|{ address="\1"; prefixLength=\2; }|' || true)"
  gateway="$(ip -4 route show default dev "$eth0_name" | awk '/default/{print $3; exit}')"
  gateway6="$(ip -6 route show default dev "$eth0_name" | awk '/default/{print $3; exit}' || true)"
  ether0="$(ip link show dev "$eth0_name" | awk '/link\/ether/{print $2; exit}')"

  nameservers="$(awk '/^nameserver/{print "\"" $2 "\""}' /etc/resolv.conf | paste -sd' ' -)"
  [ -n "$nameservers" ] || nameservers='"1.1.1.1" "8.8.8.8"'

  if [[ "$eth0_name" == eth* ]]; then
    predictable="usePredictableInterfaceNames = lib.mkForce false;"
  else
    predictable="usePredictableInterfaceNames = lib.mkForce true;"
  fi

  {
    echo "{ lib, ... }: {"
    echo "  networking = {"
    echo "    nameservers = [ $nameservers ];"
    [ -n "$gateway" ]  && echo "    defaultGateway = \"$gateway\";"
    if [ -n "$gateway6" ]; then
      echo "    defaultGateway6 = { address = \"$gateway6\"; interface = \"$eth0_name\"; };"
    fi
    echo "    dhcpcd.enable = false;"
    echo "    $predictable"
    echo "    interfaces.$eth0_name = {"
    echo "      ipv4.addresses = [ $eth0_ip4s ];"
    if [ -n "$eth0_ip6s" ]; then
      echo "      ipv6.addresses = [ $eth0_ip6s ];"
    fi
    [ -n "$gateway" ]  && echo "      ipv4.routes = [ { address = \"$gateway\"; prefixLength = 32; } ];"
    [ -n "$gateway6" ] && echo "      ipv6.routes = [ { address = \"$gateway6\"; prefixLength = 128; } ];"
    echo "    };"
    echo "  };"
    echo "  services.udev.extraRules = ''"
    echo "    ATTR{address}==\"$ether0\", NAME=\"$eth0_name\""
    echo "  '';"
    echo "}"
  }
}

makeConfigs() {
  mkdir -p "$GEN_DIR" /etc/nixos

  local keys keys_nix kmods
  keys="$(collectKeys)"
  keys_nix="$(printf '%s\n' "$keys" | awk 'NF{printf "    \"%s\"\n", $0}')"

  kmods='"ata_piix" "uhci_hcd" "xen_blkfront"'
  isX86_64 && kmods="$kmods \"vmw_pvscsi\""

  # networking.nix — may be empty if detection failed
  if networkCfg > "$GEN_DIR/networking.nix.tmp"; then
    mv "$GEN_DIR/networking.nix.tmp" "$GEN_DIR/networking.nix"
    networkImport='./networking.nix'
  else
    rm -f "$GEN_DIR/networking.nix.tmp"
    networkImport=''
  fi

  cat > "$GEN_DIR/hardware-configuration.nix" <<EOF
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

$(bootCfg)

  boot.initrd.availableKernelModules = [ $kmods ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = { device = "$rootfsdev"; fsType = "$rootfstype"; };
  ${swapcfg:-}
}
EOF

  cat > "$GEN_DIR/configuration.nix" <<EOF
{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ${networkImport:+$networkImport}
  ];

  services.logrotate.checkConfig = false;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = $zramswap;

  networking.hostName = "$NEW_HOST";
  networking.domain   = "$(hostname -d 2>/dev/null || true)";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
$keys_nix  ];

  environment.systemPackages = [ ];

  system.stateVersion = "24.11";
}
EOF

  # keep /etc/nixos as the canonical build root (nix-env wants it there)
  cp -f "$GEN_DIR"/*.nix /etc/nixos/
}

# ---------- repo scaffold ---------------------------------------------------

scaffoldRepo() {
  [ -n "${NO_REPO:-}" ] && { log "NO_REPO set — skipping repo scaffold"; return 0; }

  log "cloning $REPO_URL (branch $REPO_BRANCH) → $REPO_DIR"
  rm -rf "$REPO_DIR"
  if ! git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$REPO_DIR" 2>/tmp/infect-git.log; then
    warn "git clone failed — see /tmp/infect-git.log (continuing without repo)"
    rm -rf "$REPO_DIR"
    return 0
  fi

  local mdir="$REPO_DIR/server/machines/$NEW_HOST"
  if [ -d "$mdir" ]; then
    log "machine dir $mdir already exists in repo — leaving untouched"
  else
    log "scaffolding $mdir"
    mkdir -p "$mdir"
    cp "$GEN_DIR/hardware-configuration.nix" "$mdir/hardware-configuration.nix"

    cat > "$mdir/default.nix" <<EOF
{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # ../../services/xray
    # ../../services/health
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "$NEW_HOST";
  networking.domain   = "wiyba.org";

  time.timeZone = "Europe/Amsterdam";

  users.users.root.openssh.authorizedKeys.keys = [
    # add keys here
  ];

  system.stateVersion = "24.11";
}
EOF

    # drop a copy of the generated networking.nix alongside for manual merging
    [ -f "$GEN_DIR/networking.nix" ] && cp "$GEN_DIR/networking.nix" "$mdir/networking.nix.generated"
  fi

  cat > "$REPO_DIR/POST_INSTALL.md" <<EOF
# After first boot

\`\`\`bash
# Move repo into place (old bootstrap config is at /old-root/etc/nixos)
rmdir /etc/nixos 2>/dev/null || rm -rf /etc/nixos
mv /root/nix-config /etc/nixos
cd /etc/nixos

# 1. Add $NEW_HOST to flake.nix nixosConfigurations (copy an existing VPS block)
# 2. Merge networking.nix.generated → server/machines/$NEW_HOST/default.nix
#    (or import it directly), then delete networking.nix.generated
# 3. Build:
nh os switch

# Original generator output still lives at /etc/nixos-generated for reference.
\`\`\`
EOF
  log "post-install notes written to $REPO_DIR/POST_INSTALL.md"
}

# ---------- nix install + switch -------------------------------------------

infect() {
  groupadd -g 30000 nixbld 2>/dev/null || true
  for i in $(seq 1 10); do
    useradd -c "Nix build user $i" -d /var/empty -g nixbld -G nixbld \
            -M -N -r -s "$(command -v nologin)" "nixbld$i" 2>/dev/null || true
  done

  local NIX_INSTALL_URL="${NIX_INSTALL_URL:-https://nixos.org/nix/install}"
  curl -L "$NIX_INSTALL_URL" | sh -s -- --no-channel-add

  # shellcheck disable=SC1090
  source ~/.nix-profile/etc/profile.d/nix.sh

  nix-channel --remove nixpkgs 2>/dev/null || true
  nix-channel --add "https://nixos.org/channels/$NIX_CHANNEL" nixos
  nix-channel --update

  export NIXOS_CONFIG=/etc/nixos/configuration.nix

  nix-env --set \
    -I "nixpkgs=$(realpath "$HOME/.nix-defexpr/channels/nixos")" \
    -f '<nixpkgs/nixos>' \
    -p /nix/var/nix/profiles/system \
    -A system

  rm -fv /nix/var/nix/profiles/default*
  /nix/var/nix/profiles/system/sw/bin/nix-collect-garbage

  [ -L /etc/resolv.conf ] && {
    mv -v /etc/resolv.conf /etc/resolv.conf.lnk
    cat /etc/resolv.conf.lnk > /etc/resolv.conf
  }

  # Stage lustrate — KEEP /etc/nixos-generated and /root/nix-config out of the list
  touch /etc/NIXOS
  {
    echo etc/nixos
    echo etc/resolv.conf
    echo root/.nix-defexpr/channels
    (cd / && ls etc/ssh/ssh_host_*_key* 2>/dev/null || true)
  } > /etc/NIXOS_LUSTRATE

  # --- boot cleanup ---------------------------------------------------------
  # Old behaviour did an umount/remount dance which occasionally wedged on ESPs
  # that had sub-mounts or busy files. Instead, back up in place and wipe
  # contents of the currently-mounted ESP so the NixOS bootloader install has
  # a clean target.
  if isEFI; then
    log "cleaning ESP at $bootFs (backup at ${bootFs}.bak)"
    rm -rf "${bootFs}.bak"
    cp -a "$bootFs" "${bootFs}.bak" 2>/dev/null || warn "backup of $bootFs failed"
    find "$bootFs" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || warn "some $bootFs entries could not be removed (continuing)"
  fi

  /nix/var/nix/profiles/system/bin/switch-to-configuration boot
}

# ---------- main ------------------------------------------------------------

log "target hostname: $NEW_HOST"
log "repo: $REPO_URL @ $REPO_BRANCH"

checkEnv
prepareEnv
existingSwap
[ -z "${NO_SWAP:-}" ] && makeSwap
makeConfigs
scaffoldRepo

if [ -z "${NO_INFECT:-}" ]; then
  infect
fi

[ -z "${NO_SWAP:-}" ] && removeSwap

log "done. generated config: $GEN_DIR"
[ -d "$REPO_DIR" ] && log "repo scaffold: $REPO_DIR (see POST_INSTALL.md)"

if [ -z "${NO_REBOOT:-}" ] && [ -z "${NO_INFECT:-}" ]; then
  log "rebooting in 3s..."
  sleep 3
  reboot
fi
