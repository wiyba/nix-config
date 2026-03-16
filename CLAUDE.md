# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Repository Overview

NixOS flake-based configuration managing 6 hosts: `home`, `thinkpad` (personal machines), `stockholm`, `london`, `moscow` (VPS), and `rpi5` (Raspberry Pi 5). Uses home-manager for user environment, sops-nix for secrets, lanzaboote for secure boot on personal hosts, and nh for builds across all hosts.

## Build Commands

```bash
# Build and apply using nh (preferred, available on all hosts)
nh os switch

# Build a specific host (check without applying)
nix build /etc/nixos#nixosConfigurations.<hostname>.config.system.build.toplevel -L

# Apply configuration to current machine
sudo nixos-rebuild switch --flake /etc/nixos#<hostname>

# Hostnames: home, thinkpad, stockholm, london, moscow, rpi5
```

## Architecture

```
flake.nix                    # Inputs + nixosConfigurations (mkSystem for x86, mkRpi for ARM)
├── home/                    # home-manager config for wiyba
│   ├── programs/            # Per-program configs (waybar, zsh, firefox, foot, kitty, neovim, zed, etc.)
│   ├── scripts/             # Custom shell scripts as nix packages (each returns a list)
│   ├── shared/              # Shared base: default.nix, programs.nix, services.nix
│   ├── themes/              # GTK theme + color definitions
│   └── wm/                  # Window manager configs
│       ├── hyprland/        # Primary WM: default.nix + dotfiles (.conf, .css)
│       └── niri/            # Alternative WM
├── system/                  # Desktop/laptop system-level config
│   ├── configuration.nix    # Shared base (locale, programs, user, home-manager, nh)
│   ├── machines/            # Per-host: home/, thinkpad/, nix-usb/
│   │   ├── home/            # Desktop (AMD GPU, dual monitors, media server, sing-box, Terraria)
│   │   └── thinkpad/        # Laptop (LUKS, TPM2, fingerprint, modem, TLP)
│   ├── secrets/             # SOPS encrypted secrets (desktop/laptop)
│   │   ├── default.nix      # Secrets module (hysteria-auth, trojan-auth, github_token, ssh, git-creds)
│   │   ├── secrets.yaml     # Encrypted secrets file
│   │   └── .sops.yaml       # SOPS configuration rules
│   └── services/            # System-level service modules
│       ├── greetd/          # Login manager (tuigreet)
│       ├── hyst-panel/      # Hysteria management panel (home only)
│       ├── mihomo/          # Proxy daemon (Hysteria2 on home, Trojan on thinkpad)
│       ├── nginx/           # Reverse proxy (media/music/home/hyst.wiyba.org, Cloudflare ACME)
│       ├── pipewire/        # Audio server
│       └── ssh/             # SSH daemon
├── server/                  # VPS + rpi5 system-level config
│   ├── configuration.nix    # Shared server base (root user, firewall, nh)
│   ├── machines/            # Per-host: stockholm/, london/, moscow/, rpi5/
│   ├── programs/            # Server programs (git, ssh, zsh)
│   ├── services/            # hysteria, remnanode, satisfactory, sshd
│   └── secrets/             # Server-specific encrypted secrets (hysteria excluded for rpi5)
└── overlays/                # Custom package overlays (musicpresence, navidrome pin, proxmark3)
```

## Key Patterns

- **home-manager entry point**: `system/configuration.nix` imports `../home/wm/hyprland` as `home-manager.users.wiyba`
- **Per-host home config**: Injected via `home-manager.users.wiyba.xdg.configFile` in `system/machines/<host>/default.nix` (monitor layout, hypridle, etc.)
- **`host` variable**: Passed through `specialArgs` and `extraSpecialArgs`, available in all modules for per-host logic
- **Host-specific modules**: Use `lib.mkMerge` + `lib.mkIf (host == "hostname")` pattern in `system/services/`
- **Scripts convention**: Each `.nix` in `home/scripts/` is loaded via `callPackage` and must return a **list of packages** (use `[ (writeShellScriptBin ...) ]`). Collected by `lib.concatMap` in `home/shared/default.nix`
- **Flake module paths**: Use `(base + "/path")` (path concatenation), NOT `"${base}/path"` (string interpolation), to preserve relative imports inside modules
- **Two flake builders**: `mkSystem` (x86 hosts via `nixpkgs.lib.nixosSystem`) and `mkRpi` (ARM hosts via `nixos-raspberrypi.lib.nixosSystem` with `nixos-raspberrypi` in specialArgs)
- **Conditional secrets**: Server secrets use `lib.mkIf` to exclude hysteria config for rpi5

## Key Details

- **Flake inputs**: nixpkgs (unstable), nixpkgs-navidrome (pinned), home-manager, sops-nix, lanzaboote, lazyvim-nix, nixos-hardware, nixos-raspberrypi, NUR, nix-index-database, hyst-panel
- **Secrets**: SOPS with age encryption. Two independent secret stores: `system/secrets/` (desktop) and `server/secrets/` (servers). Edit with `sops /etc/nixos/system/secrets/secrets.yaml` or `server/secrets/secrets.yaml`
- **Desktop stack**: Hyprland (via UWSM) + Niri + greetd/tuigreet + Waybar + Foot/Kitty + PipeWire
- **Media services** (home only): Jellyfin (HW accel via VAAPI) + Navidrome (pinned nixpkgs) + Nginx reverse proxy
- **Proxy setup**: mihomo with Hysteria2 (home→stockholm/london) + Trojan (thinkpad→home); sing-box trojan inbound on home
- **NixOS version**: 24.11 stateVersion, nixos-unstable channel
- **User**: `wiyba` on home/thinkpad, `root` on servers
- **Overlays**: musicpresence (Discord music presence), navidrome (pinned), proxmark3 (custom build)

## Host-Specific Features

| Host | Key Features |
|------|-------------|
| `home` | AMD GPU, dual 1440p monitors, Jellyfin/Navidrome, Nginx, NAT, hyst-panel, sing-box trojan, Terraria server |
| `thinkpad` | LUKS, TPM2, fingerprint, ModemManager, TLP power management, mihomo trojan client |
| `stockholm` | VPS (x86), Hysteria server |
| `london` | VPS (x86), Hysteria server, Satisfactory game server, IPv6 |
| `moscow` | VPS (x86), Hysteria server, IPv6 |
| `rpi5` | Raspberry Pi 5 (aarch64), nixos-raspberrypi, proxmark3, NetworkManager, no Hysteria |
