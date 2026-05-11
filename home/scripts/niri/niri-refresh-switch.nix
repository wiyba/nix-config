{ writeShellScriptBin, niri, ... }:

[
  (writeShellScriptBin "niri-refresh-switch" ''
    set -euo pipefail
    status="$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 1)"
    if [ "$status" = "1" ]; then
      ${niri}/bin/niri msg output eDP-1 mode 2880x1800@120
    else
      ${niri}/bin/niri msg output eDP-1 mode 2880x1800@60
    fi
  '')
]
