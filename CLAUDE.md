# CLAUDE.md

NixOS flake driving all my machines. Desktops in `system/` (user `wiyba`, home-manager, Niri), servers in `server/` (user `root`), per-host proxy roles in `proxy/`, single sops store in `secrets/`. The authoritative host list is `nixosConfigurations` in `flake.nix` — read it there, never trust docs or memory for it.

## Hard rules

- Never build or apply configs (`nh os switch`, `nixos-rebuild`, `nix build` of a toplevel). I deploy myself: SSH into the host, rebuild locally. Never suggest `--target-host` / remote builds / pushing closures.
- Eval-only verification: `nix eval /etc/nixos#nixosConfigurations.<host>.config.system.build.toplevel.drvPath --raw`, or `nix flake check /etc/nixos` when touching shared files. `git add` new files first — flake eval ignores untracked files.
- No `boot.kernel.sysctl` network/TCP tuning (BBR, fq, TFO, MTU probing, …) — a past attempt destabilized the mihomo→xray proxy chain. Tune only app-level xray/mihomo config. The existing hardening sysctls stay.
- Secrets never appear in `.nix` files — only sops placeholders/templates (`secrets/secrets.yaml`; `sops -d` works from my shell).
- Format `.nix` with `nixpkgs-fmt`.

## Mechanics

- `host`, `isServer`, `wm`, `inputs` come via specialArgs; per-host gating via `lib.mkIf (host == "…")` or host-keyed attrsets.
- Flake module paths: `(base + "/path")`, never `"${base}/path"` — interpolation breaks relative imports inside modules.
- `proxy/default.nix` maps host → proxy modules; per-host mihomo differences live in the `hosts` table at the top of `proxy/mihomo.nix`.
- `home/scripts/<group>/*.nix` are auto-discovered: `shared/` files return package lists, WM dirs return modules.
- mihomo/xray set `restartIfChanged = false` — tell me to restart them manually when their config changed.
- New sops host: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub` → add to `secrets/.sops.yaml` → `cd secrets && sops updatekeys secrets.yaml`.
