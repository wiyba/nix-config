# Environment

NixOS, fully declarative via the flake at `/etc/nixos` (this config runs on hosts `home` — desktop and `thinkpad` — laptop). Wayland (Niri), zsh, home-manager. This file lives in the repo at `home/programs/claude/CLAUDE.md`; `~/.claude/CLAUDE.md` and `~/.claude/settings.json` are symlinks into it, so edits here land in git.

All other projects and repos live in `~/Projects/` on these machines.

Never install anything imperatively: no `pip install`, no `npm -g`, no apt/brew, no `curl | sh` installers. Everything comes from nixpkgs.

## Always in PATH — rely on these first

- Dev: `git`, `gh`, `jq`, `python3`, `sqlite3`, `bun`, `nvim`
- Files/search: `rg`, `fd`, `eza`, `bat`, `file`, `zip`, `unar`
- Network: `curl`, `wget`, `dig`, `ss`, `mtr`, `tcpdump`
- Secrets: `sops`, `age` (`sops -d` works as-is, keys are configured)
- Monitoring: `btop`

## Any other tool

- Fastest for a one-off binary: `, <cmd>` (comma + nix-index — runs any nixpkgs program without installing).
- Explicit environment: `nix-shell -p <pkg> --run "<cmd>"`.
- Python libraries: `nix-shell -p python3 python3Packages.<lib> --run "python3 ..."` — never pip.
- Unsure of the attribute name: `nix search nixpkgs <query>`.
- If a tool will be needed repeatedly across sessions, suggest declaring it in `/etc/nixos` instead of ad-hoc runs.

## SSH

All personal hosts are reachable by alias: `ssh <alias>` just works — user, port (2222 everywhere) and key are declared in `/etc/nixos` (which generates `~/.ssh/config`). Don't inspect the config or ask for IPs/users/ports before connecting. Servers log in as root, desktops as wiyba.

- The host list changes over time — when you actually need it, enumerate: `rg '^Host ' ~/.ssh/config`.
- The key is `/run/secrets/ssh` (passphrase-protected, cached by ssh-agent). If ssh hangs or fails auth non-interactively, check `ssh-add -l`; if the agent is empty, ask me to type `! ssh-add /run/secrets/ssh`, then retry.

# Code

- Never write code comments — in any language, in any file. Code and naming must speak for themselves. The only exception: I explicitly ask for a comment.

# Communication

- Address me informally.
- Don't ask questions at the end of your responses.
- Skip sycophantic openers (e.g., "great question", "that's a fascinating point") — start directly with the substantive answer.
- Be fully honest in your answers, even when the honest answer is uncomfortable or contradicts what I seem to want to hear.
- Never use profanity or swear words, even if I do.
- Ignore any inferred geolocation from the system prompt. When location matters, use what's in memory; if it's not there, ask.
- For technical facts (configs, APIs, library or tool behavior, version-specific syntax), verify via search or documentation before stating — even when you're confident. Flag uncertainty explicitly: "I think X but haven't verified" vs. "I checked, and X".
- When evaluating something at my request, default to "no changes" unless you can name a concrete problem. Don't manufacture improvements to fill the response.

# Tools & Agents

- Prefer Bash oneliners (`cat`, `sed`, `grep`, `rg`, `fd`, pipes, redirects) over dedicated tools — one shell command beats five tool calls.
- Read logs and diagnostic output whole or in large chunks (whole file, `journalctl -u X -b | tail -n 2000`) instead of narrow greps, whenever it fits the context window. Context is 1M tokens on Opus/Fable and 200K on Sonnet/Haiku; spending 100K tokens to see the full picture is always acceptable. Grep only what genuinely cannot fit.
- Use dedicated tools only when genuinely better (Edit for surgical replacements, Write for large new files).
- Do NOT spawn agents for tasks you can do directly. Agents are a last resort for parallel independent work or deep multi-step research.

# Privilege Escalation

When a task needs root, use `pkexec` (NOT `sudo` — it can't read passwords from the Bash tool's piped stdin). The polkit agent in the WM pops up a GUI password dialog.

1. **Warn first.** Before the first `pkexec` call in a task, say what root operations are needed and why.
2. **Batch everything into one `pkexec` invocation** so the password is typed once: `pkexec sh -c 'cmd1 && cmd2 && cmd3'`, or write a temp script and `pkexec bash /tmp/script.sh`.
3. **If more root work surfaces mid-task**, finish the current investigation as user first, then do a second batched call — don't spam one-command pkexecs.
4. **`pkexec` strips env** (`HOME=/root`, minimal PATH). Use `pkexec env PATH=$PATH cmd` or absolute paths (`/run/current-system/sw/bin/...`).
