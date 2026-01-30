# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

NixOS flake-based configuration managing 3 hosts: `desktop`, `thinkpad` (personal machines) and `stockholm`, `london` (VPS). Uses home-manager for user environment, sops-nix for secrets, and lanzaboote for secure boot on personal hosts.
## Build Commands

```bash
# Build a specific host (check without applying)
nix build /etc/nixos#nixosConfigurations.<hostname>.config.system.build.toplevel -L

# Apply configuration to current machine
sudo nixos-rebuild switch --flake /etc/nixos#<hostname>

# Hostnames: desktop, thinkpad, stockholm, london
```

## Architecture

```
flake.nix                    # Inputs + nixosConfigurations for all hosts
├── home/                    # home-manager config for wiyba (top-level)
│   ├── programs/            # Per-program configs (waybar, zsh, firefox, foot, etc.)
│   ├── scripts/             # Shell scripts as nix packages (each returns a list)
│   ├── shared/              # Shared base: default.nix, programs.nix, services.nix
│   ├── themes/              # GTK theme + color definitions
│   └── wm/                  # Window manager configs
│       └── hyprland/        # Hyprland: default.nix + dotfiles (.conf, .css)
├── system/                  # Desktop/laptop system-level config
│   ├── configuration.nix    # Shared base (networking, locale, programs, user, home-manager)
│   ├── machines/            # Per-host: desktop/ and thinkpad/
│   ├── services/            # greetd, mihomo, pipewire, systemd
│   └── secrets/             # SOPS encrypted secrets
└── server/                  # VPS system-level config
    ├── configuration.nix    # Shared server base
    ├── machines/            # Per-host config
    ├── home/                # home-manager for root
    ├── services/            # hysteria, remnanode
    └── sops/                # Encrypted secrets
```

## Key Patterns

- **home-manager entry point**: `system/configuration.nix` imports `../home/wm/hyprland` as `home-manager.users.wiyba`
- **Per-host home config**: Injected via `home-manager.users.wiyba.xdg.configFile` in `system/machines/<host>/default.nix` (monitor layout, hypridle, etc.)
- **`host` variable**: Passed through `specialArgs` and `extraSpecialArgs`, available in all modules for per-host logic
- **Scripts convention**: Each `.nix` in `home/scripts/` is loaded via `callPackage` and must return a **list of packages** (use `[ (writeShellScriptBin ...) ]`). Collected by `lib.concatMap` in `home/shared/default.nix`
- **Flake module paths**: Use `(base + "/path")` (path concatenation), NOT `"${base}/path"` (string interpolation), to preserve relative imports inside modules

## Key Details

- **Flake inputs**: nixpkgs (unstable), home-manager, sops-nix, lanzaboote, lazyvim-nix, nixos-hardware, NUR, nix-index-database
- **Secrets**: SOPS with age encryption. Key file at `/etc/nixos/keys/sops-age.key`. Edit with `sops /etc/nixos/system/secrets/secrets.yaml` or `server/sops/secrets.yaml`
- **Desktop stack**: Hyprland (via UWSM) + greetd/tuigreet + Waybar + Foot + PipeWire
- **NixOS version**: 24.11 stateVersion, nixos-unstable channel
- **User**: `wiyba` on desktop/thinkpad, `root` on servers
