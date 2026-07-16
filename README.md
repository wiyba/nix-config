nix-config [![ci-badge](https://img.shields.io/static/v1?label=Built%20with&message=nix&color=blue&style=flat&logo=nixos&link=https://nixos.org&labelColor=111212)](https://wiyba.org) [![systems](https://github.com/wiyba/nix-config/actions/workflows/systems.yml/badge.svg)](https://github.com/wiyba/nix-config/actions/workflows/systems.yml) [![servers](https://github.com/wiyba/nix-config/actions/workflows/servers.yml/badge.svg)](https://github.com/wiyba/nix-config/actions/workflows/servers.yml)
==========

my [nixos](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager/) configuration - a single flake driving 5 machines: two personal x86_64 boxes, two x86_64 vps nodes and one raspberry.

## hosts
| host | arch | role |
| :--- | :--- | :--- |
| `home` | x86_64 | home desktop + router (nat, jellyfin/navidrome, nginx) |
| `thinkpad` | x86_64 | laptop (luks, tpm2, fingerprint, 4g modem) |
| `stockholm` | x86_64 | vps node + mail server |
| `almaty` | x86_64 | vps node (for experiments) |
| `nest` | aarch64 | rpi5 country house router |

## stack
| type | program |
| :--- | :--- |
| window manager | [niri](https://github.com/YaLTeR/niri) |
| status bar | [noctalia](https://github.com/noctalia-dev/noctalia-shell) |
| shell | [zsh](https://www.zsh.org/) |
| terminal | [kitty](https://sw.kovidgoyal.net/kitty/) |
| editor | [zed](https://zed.dev/) |
| browser | [firefox](https://www.mozilla.org/firefox/) |

## layout
- `flake.nix` - inputs + `nixosConfigurations` (`mkSystem` for x86, `mkRpi` for the pi)
- `home/` - home-manager (per-wm entry under `home/wm/<wm>`)
- `system/` - desktop + laptop config (`home`, `thinkpad`)
- `server/` - vps + pi config (`stockholm`, `almaty`, `nest`)
- `proxy/` - per-host proxy roles (xray server, mihomo, xcli, admin api)
- `secrets/` - sops store
- `overlays/` - some custom packages

## license
released under the Unlicense — see [LICENSE](./LICENSE) or https://unlicense.org for details.
