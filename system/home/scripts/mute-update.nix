{ pkgs, ... }:
let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  awk = "${pkgs.gawk}/bin/awk";
in
pkgs.writeShellScriptBin "mute-update" ''
  #!/bin/sh
  set -euo pipefail
  LED="/sys/class/leds/platform::mute/brightness"
  MAX="$(cat "$(dirname "$LED")/max_brightness" 2>/dev/null || echo 1)"
  write_led() {
    local v="$1"
    if [ "$v" -gt "$MAX" ]; then v="$MAX"; fi
    printf '%s\n' "$v" | tee "$LED" >/dev/null
  }
  is_muted=false
  vol_percent=0
  if command -v ${wpctl} >/dev/null 2>&1; then
    line="$(${wpctl} get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    if [ -n "''${line}" ]; then
      if printf '%s' "$line" | grep -qi 'muted'; then
        is_muted=true
      fi
      vol_float="$(printf '%s\n' "$line" | ${awk} '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+([.][0-9]+)?$/){print $i; exit}}')"
      if [ -n "''${vol_float:-}" ]; then
        vol_percent="$(${awk} -v v="$vol_float" 'BEGIN{printf("%d\n", v*100 + 0.5)}')"
      else
        vol_percent=0
      fi
    fi
  fi
  if [ -z "''${line:-}" ] && command -v ${pactl} >/dev/null 2>&1; then
    mute_word="$(${pactl} get-sink-mute @DEFAULT_SINK@ 2>/dev/null | ${awk} '{print tolower($2)}' || true)"
    if [ "$mute_word" = "yes" ]; then
      is_muted=true
    fi
    vol_percent="$(${pactl} get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -n1 | tr -d '%' || echo 0)"
    vol_percent="''${vol_percent:-0}"
  fi
  if $is_muted || [ "''${vol_percent:-0}" -eq 0 ]; then
    write_led 1
  else
    write_led 0
  fi
''
