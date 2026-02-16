# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Repository Overview

NixOS flake-based configuration managing 4 hosts: `home`, `thinkpad` (personal machines) and `stockholm`, `london` (VPS). Uses home-manager for user environment, sops-nix for secrets, and lanzaboote for secure boot on personal hosts.

## Build Commands

```bash
# Build a specific host (check without applying)
nix build /etc/nixos#nixosConfigurations.<hostname>.config.system.build.toplevel -L

# Apply configuration to current machine
sudo nixos-rebuild switch --flake /etc/nixos#<hostname>

# Hostnames: home, thinkpad, stockholm, london
```

## Architecture

```
flake.nix                    # Inputs + nixosConfigurations for all hosts
├── home/                    # home-manager config for wiyba
│   ├── programs/            # Per-program configs (waybar, zsh, firefox, foot, neovim, etc.)
│   ├── packages/            # Custom shell scripts as nix packages (each returns a list)
│   ├── shared/              # Shared base: default.nix, programs.nix, services.nix
│   ├── themes/              # GTK theme + color definitions
│   └── wm/                  # Window manager configs
│       ├── hyprland/        # Primary WM: default.nix + dotfiles (.conf, .css)
│       └── niri/            # Alternative WM
├── system/                  # Desktop/laptop system-level config
│   ├── configuration.nix    # Shared base (locale, programs, user, home-manager)
│   ├── machines/            # Per-host: home/, thinkpad/, nix-usb/
│   │   ├── home/            # Desktop machine (AMD GPU, dual monitors, media server)
│   │   └── thinkpad/        # Laptop (LUKS, TPM2, fingerprint, modem)
│   └── modules/             # System-level service modules
│       ├── greetd/          # Login manager (tuigreet)
│       ├── networking/      # Host-specific networking (NAT, firewall, DNS)
│       ├── mihomo/          # Proxy daemon (Hysteria2, VLESS)
│       ├── nginx/           # Reverse proxy (Jellyfin, Navidrome, etc.)
│       ├── media/           # Media services (Jellyfin, Navidrome)
│       ├── pipewire/        # Audio server
│       └── systemd/         # Systemd-user services
├── server/                  # VPS system-level config
│   ├── configuration.nix    # Shared server base
│   ├── machines/            # Per-host: stockholm/, london/
│   ├── programs/            # Server programs (git, ssh, zsh)
│   ├── services/            # hysteria, remnanode, sshd
│   └── secrets/             # Server-specific encrypted secrets
├── secrets/                 # SOPS encrypted secrets (desktop/laptop)
│   ├── default.nix          # Secrets configuration module
│   ├── secrets.yaml         # Encrypted secrets file
│   ├── .sops.yaml           # SOPS configuration rules
│   └── sops-age.key         # Age private key (not in git)
└── overlays/                # Custom package overlays
```

## Key Patterns

- **home-manager entry point**: `system/configuration.nix` imports `../home/wm/hyprland` as `home-manager.users.wiyba`
- **Per-host home config**: Injected via `home-manager.users.wiyba.xdg.configFile` in `system/machines/<host>/default.nix` (monitor layout, hypridle, etc.)
- **`host` variable**: Passed through `specialArgs` and `extraSpecialArgs`, available in all modules for per-host logic
- **Host-specific modules**: Use `lib.mkMerge` + `lib.mkIf (host == "hostname")` pattern in `system/modules/`
- **Packages convention**: Each `.nix` in `home/packages/` is loaded via `callPackage` and must return a **list of packages** (use `[ (writeShellScriptBin ...) ]`). Collected by `lib.concatMap` in `home/shared/default.nix`
- **Flake module paths**: Use `(base + "/path")` (path concatenation), NOT `"${base}/path"` (string interpolation), to preserve relative imports inside modules

## Key Details

- **Flake inputs**: nixpkgs (unstable), home-manager, sops-nix, lanzaboote, lazyvim-nix, nixos-hardware, NUR, nix-index-database
- **Secrets**: SOPS with age encryption. Key file at `/etc/nixos/secrets/sops-age.key`. Edit with `sops /etc/nixos/secrets/secrets.yaml` or `server/secrets/secrets.yaml`
- **Desktop stack**: Hyprland (via UWSM) + greetd/tuigreet + Waybar + Foot + PipeWire
- **Media services** (home only): Jellyfin (HW accel via VAAPI) + Navidrome + Nginx reverse proxy
- **Proxy setup**: mihomo with Hysteria2 + VLESS routing to stockholm/london VPS
- **NixOS version**: 24.11 stateVersion, nixos-unstable channel
- **User**: `wiyba` on home/thinkpad, `root` on servers

## Host-Specific Features

| Host | Key Features |
|------|-------------|
| `home` | AMD GPU, dual 1440p monitors, Jellyfin/Navidrome media server, Nginx, NAT between interfaces |
| `thinkpad` | LUKS encryption, TPM2, fingerprint auth, ModemManager, lid switch handlers |
| `stockholm` | VPS, Hysteria server |
| `london` | VPS, Hysteria server |
