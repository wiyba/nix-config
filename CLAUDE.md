# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Repository Overview

NixOS flake managing 6 hosts:
- **Personal x86_64**: `home` (desktop, primary-location edge router), `thinkpad` (laptop)
- **VPS x86_64**: `relay`, `london`, `stockholm`
- **ARM**: `nest` (Raspberry Pi 5, secondary-location edge router)

Stack: home-manager for user environment, sops-nix with **per-host SSH-key-derived age recipients**, lanzaboote for Secure Boot (home/thinkpad), `nh` for builds.

## Build Commands

```bash
# Build and apply (preferred, available everywhere)
nh os switch

# Eval / build a specific host without applying
nix build /etc/nixos#nixosConfigurations.<hostname>.config.system.build.toplevel -L

# Apply via stock nixos-rebuild
sudo nixos-rebuild switch --flake /etc/nixos#<hostname>

# Hostnames: home, thinkpad, london, stockholm, relay, nest
```

## Agent rules

- **Do NOT run `nh os switch` / `nixos-rebuild switch` / `boot` / `nix build` of the toplevel** — the user applies configs manually, and a full build is wasted work when only the eval state matters.
- **When unsure a change evaluates**, do an eval-only check (writes only the `.drv` to the store, no builders run):
  - One host: `nix eval /etc/nixos#nixosConfigurations.<host>.config.system.build.toplevel.drvPath --raw`
  - All flake outputs at once (when touching shared files like `flake.nix`, `secrets/`, `system/configuration.nix`, `server/configuration.nix`): `nix flake check /etc/nixos`
  - This catches module type errors, missing options, assertion failures, bad paths. It does NOT catch builder-time failures inside upstream packages — those are upstream's problem, not the config's.
- **Prefer this CLAUDE.md over auto-memory `feedback` notes.** If something is a durable, repo-wide rule worth remembering, suggest adding it here so it lands in git and is visible. Don't write a feedback memory unless the rule is genuinely critical and the user explicitly asks.
- **Don't propose `boot.kernel.sysctl` TCP/network tuning** (BBR, fq, TFO, MTU probing, tcp_notsent_lowat, etc.). A prior attempt destabilized the `home (mihomo) → relay (xray) → exit-server` proxy chain. For latency/throughput, only app-level levers (xray/mihomo config: DNS, sniffing, routing strategy, outbound strategy, unified-delay, tcp-concurrent). Existing sysctl entries (hardening + somaxconn/backlog) stay.
- **User deploys by SSH'ing into the target host and running `nixos-rebuild` / `nh os switch` locally** — never via `--target-host` or `--build-host`. Don't suggest remote-build / push-closure even on slow nodes (RPi, e2-small). If a build is slow, suggest waiting, gc, or binary cache — not remote build.

## Architecture

```
flake.nix                    # Inputs + nixosConfigurations (mkSystem for x86, mkRpi for aarch64)
├── home/                    # home-manager config for wiyba (per-WM entry: home/wm/<wm>)
│   ├── programs/            # Per-program HM modules (kitty, foot, neovim, zed, firefox, waybar, uxplay, ...)
│   ├── scripts/             # Custom shell scripts as nix packages
│   │   ├── shared/          # All-WM (pactl-listener, proxy)
│   │   ├── hyprland/        # Hyprland-only (bitwarden-handler, close-special-workspace, get-weather)
│   │   └── niri/            # Niri-only (niri-refresh-switch)
│   ├── shared/              # Base entry: default.nix (xdg, mimeApps, fonts, GTK/Qt theme)
│   │                        #             programs.nix (per-program imports + ssh matchBlocks),
│   │                        #             services.nix (ssh-agent, gnome-keyring, polkit-agent)
│   └── wm/
│       ├── hyprland/        # Hyprland WM module + .conf dotfiles
│       └── niri/            # Niri WM module + .kdl dotfiles  ← default for home/thinkpad
├── system/                  # Desktop/laptop system-level config
│   ├── configuration.nix    # Shared base (locale, programs, user, sysctl hardening, avahi NOT in base)
│   ├── machines/
│   │   ├── home/            # Edge router LAN1: wan0/lan0, NAT, firewall, jellyfin, navidrome, nginx, mihomo, xray, fail2ban
│   │   ├── thinkpad/        # Laptop: LUKS, TPM2, fingerprint, ModemManager (4G modem), TLP, mihomo client
│   │   └── nix-usb/         # Offline-installer image (NOT in flake nixosConfigurations)
│   └── services/            # System service modules
│       ├── greetd/          # Login manager (tuigreet)
│       ├── mihomo/          # Mihomo proxy client (TUN, fake-ip, auto-route)
│       ├── nginx/           # Reverse proxy + Cloudflare ACME (DNS-01) + wba-website systemd unit
│       ├── pipewire/        # Audio server (per-host filter-chains)
│       ├── printing/        # CUPS + avahi (LAN-bound, only imported by home/)
│       ├── ssh/             # sshd port 2222 + fail2ban (nftables backend)
│       └── xcli/            # github:wiyba/xcli — VLESS user/admin manager
├── server/                  # VPS + nest
│   ├── configuration.nix    # Shared server base (root user, sysctl hardening, sops, nh)
│   ├── machines/
│   │   ├── london/, stockholm/, relay/   # VPS configs
│   │   └── nest/            # ARM edge router LAN2
│   ├── programs/            # Server programs (git, ssh, zsh)
│   └── services/
│       ├── acme/            # Cloudflare DNS-01
│       ├── hysteria/        # Legacy Hysteria server (in transition)
│       ├── mihomo/          # Mihomo on relay (socks, no TUN — chains upstream)
│       ├── remnanode/       # Remnawave node (currently off)
│       ├── satisfactory/    # Game server (london, optional)
│       ├── sshd/            # sshd + fail2ban (nftables backend)
│       └── xray/            # Xray VLESS Reality server
├── secrets/                 # SINGLE SOPS store (used by both system and server trees)
│   ├── default.nix          # sops module: per-host secrets, templates, gated via isServer
│   ├── secrets.yaml         # Encrypted; recipients = user + per-host SSH-derived age keys
│   ├── .sops.yaml           # Recipients list
│   └── sops-age.key         # LEGACY shared key — kept as fallback, removable after all hosts migrate
└── overlays/                # Custom packages (musicpresence, proxmark3, terminal-oscilloscope)
```

## Key Patterns

- **home-manager entry**: `system/configuration.nix` does `home-manager.users.wiyba = import (../home/wm + "/${wm}")` where `wm` is set in flake.nix per host (`"niri"` for both home/thinkpad currently).
- **Per-host home config**: Injected via `home-manager.users.wiyba.xdg.configFile` in `system/machines/<host>/default.nix` (monitor layout, hypridle).
- **`host` variable**: Passed through `specialArgs` and `extraSpecialArgs`. Use for `lib.mkIf (host == "X")` gating. Examples: `home/programs/uxplay` (only on home), `home/programs/easyeffects` (off on thinkpad).
- **Scripts convention**: Each `.nix` in a `home/scripts/<group>/` subdir is `callPackage`-loaded and must return a **list of packages** (e.g., `[ (writeShellScriptBin ...) ]`). Auto-discovered by `builtins.readDir` in each subdir's `default.nix`. `shared/` returns a list (consumed via `lib.concatMap import` in `home/shared/default.nix`); `hyprland/` and `niri/` return modules (consumed via WM-level `imports = [...]`).
- **Flake module paths**: Use `(base + "/path")` (path concatenation), NOT `"${base}/path"` (string interpolation), to preserve relative imports inside modules.
- **Two flake builders**: `mkSystem` (x86 via `nixpkgs.lib.nixosSystem`) and `mkRpi` (aarch64 via `nixos-raspberrypi.lib.nixosSystem` with `nixos-raspberrypi` in specialArgs).
- **Interface renaming**: `home` and `nest` use `systemd.network.links` to rename WAN/LAN interfaces by MAC to `wan0`/`lan0` (consistent edge-router naming).
- **`isServer` gating**: `secrets/default.nix` uses `isServer` (set via flake `specialArgs` based on `base == ./server`) to skip desktop-only templates (`git-creds-wiyba`, ssh.key path) on servers.
- **Networking via DHCP where available**: Hosts where provider offers DHCP (`relay`, `stockholm`) use NixOS default (`dhcpcd`) — no `networking.interfaces.*` or `defaultGateway` in their configs. Static-only hosts (`london`) use systemd-networkd with `sops.templates` writing `/etc/systemd/network/*.network` so IP literals stay out of the repo. Matching by `MACAddress=` (not `Name=`) for robustness across VM bus reshuffling.

## Key Details

- **Flake inputs**: nixpkgs (unstable), home-manager, sops-nix, lanzaboote, lazyvim, nixos-hardware, nixos-raspberrypi, NUR, nix-index-database, claude-code-nix, noctalia, nsticky, xcli, wba-website
- **SOPS**: Per-host age recipients derived from each host's `/etc/ssh/ssh_host_ed25519_key` (auto-picked by sops-nix when openssh is enabled). User's personal age key in `~/.config/sops/age/keys.txt` for CLI editing. `sops -d /etc/nixos/secrets/secrets.yaml` works without env var. Adding a new host: get its `/etc/ssh/ssh_host_ed25519_key.pub`, run `ssh-to-age` on it, add to `.sops.yaml`, then `cd /etc/nixos/secrets && sops updatekeys secrets.yaml`.
- **Secrets schema**: `xray.<host>.{key_priv, key_pub, sid, ip, gw, ipv6, gw6}` uniform shape for all xray hosts (relay/london/stockholm); fields not applicable per host (e.g. relay's `gw`/`ipv6`/`gw6`) are set to `"unused"` to keep the parsing loop in `secrets/default.nix` flat without conditionals.
- **Desktop stack**: Hyprland (via UWSM) and Niri (default) + greetd/tuigreet + Waybar (Hyprland) / Noctalia (Niri) + Kitty + PipeWire.
- **Media services** (home only): Jellyfin (HW VAAPI) + Navidrome + nginx vhosts (media.wiyba.org, music.wiyba.org).
- **Proxy setup**: Xray VLESS Reality server on relay/london/stockholm; mihomo client on home (TUN, fake-ip, auto-route via relay) and thinkpad. Relay's mihomo chains upstream to overseas hops. `nest` has **NO mihomo** (uses upstream network directly).
- **Network hardening**: `boot.kernel.sysctl` block in both system/ and server/ bases (accept_redirects=0 v4+v6, send_redirects=0, rp_filter=2 loose, log_martians=1, tcp_max_syn_backlog=4096, somaxconn=4096). NixOS firewall on home: `trustedInterfaces=[lan0]`, `allowedTCPPorts=[80 443 2222 18095 25565 27036 27037]`, `allowedUDPPorts=[18095]`, `allowedUDPPortRanges=[27031-27036]` (Steam Remote Play). On london/stockholm/relay/nest/thinkpad — fail2ban+nftables declared in `server/services/sshd` and `system/services/ssh`, active where rolled out (currently home + relay; rest pending).
- **Edge routing**: `home` and `nest` are NAT gateways for their LANs (192.168.1.0/24). NM-shared on `lan0` handles DHCP (dnsmasq) + DNS forwarding + masquerade automatically.
- **Formatter**: zed configured to use `nixpkgs-fmt` (less aggressive about line-breaking than `nixfmt-rfc-style`). All `.nix` files in this repo follow nixpkgs-fmt style.
- **NixOS version**: 24.11 stateVersion, `nixos-unstable` channel.
- **User**: `wiyba` on home/thinkpad, `root` on servers/nest.
- **Overlays**: musicpresence (Discord music presence), proxmark3 (custom build), terminal-oscilloscope.
- **xcli / hcli**: `xcli` (deployed via `inputs.xcli`, exposed as `system/services/xcli`) — VLESS Reality user/admin manager. `hcli` is planned (similar to xcli but for Hysteria, replaces removed `hyst-panel`); Hysteria is more conspicuous to DPI than VLESS Reality, so VLESS Reality is the primary protocol now.

## Host-Specific Features

| Host | Role | Key Features |
|------|------|--------------|
| `home` | Desktop + primary edge router | AMD GPU, dual 1440p, Jellyfin / Navidrome, nginx, NAT (wan0/lan0), mihomo+xray client, fail2ban, uxplay AirPlay receiver (HM user service), qBittorrent, wba-website systemd |
| `thinkpad` | Mobile laptop | LUKS, TPM2, fingerprint, 4G modem (ModemManager), TLP, mihomo client, `modem-fix` post-resume USB-reset |
| `london` | VPS (proxy node) | Xray Reality, nginx 8443, optional Satisfactory server, systemd-networkd via sops template (static — provider has no DHCP) |
| `stockholm` | VPS (proxy node) | Xray Reality, dhcpcd default (provider DHCP + IPv6 RA work) |
| `relay` | VPS (proxy chain edge) | Xray Reality, mihomo socks chain to upstream, nginx 8443, **fail2ban+nftables active**, dhcpcd default (cloud DHCP) |
| `nest` | ARM secondary edge router | nixos-raspberrypi, NM-shared NAT (wan0/lan0), proxmark3 |
