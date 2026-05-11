{ pulseaudio, wireplumber, gawk, writeShellScriptBin, ... }:

let
  pactl = "${pulseaudio}/bin/pactl";
  wpctl = "${wireplumber}/bin/wpctl";
  awk = "${gawk}/bin/awk";

  mkLedUpdater = { name, led, wpctlTarget, pactlMuteCmd, pactlVolCmd }:
    writeShellScriptBin name ''
      set -euo pipefail
      LED="${led}"
      MAX="$(cat "$(dirname "$LED")/max_brightness" 2>/dev/null || echo 1)"
      write_led() {
        local v="$1"
        if [ "$v" -gt "$MAX" ]; then v="$MAX"; fi
        printf '%s\n' "$v" | tee "$LED" >/dev/null
      }
      is_muted=false
      vol_percent=0
      line=""
      if command -v ${wpctl} >/dev/null 2>&1; then
        line="$(${wpctl} get-volume ${wpctlTarget} 2>/dev/null || true)"
        if [ -n "$line" ]; then
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
        mute_word="$(${pactlMuteCmd} 2>/dev/null | ${awk} '{print tolower($2)}' || true)"
        if [ "$mute_word" = "yes" ]; then
          is_muted=true
        fi
        vol_percent="$(${pactlVolCmd} 2>/dev/null | grep -oE '[0-9]+%' | head -n1 | tr -d '%' || echo 0)"
        vol_percent="''${vol_percent:-0}"
      fi
      if $is_muted || [ "''${vol_percent:-0}" -eq 0 ]; then
        write_led 1
      else
        write_led 0
      fi
    '';

  muteUpdate = mkLedUpdater {
    name = "mute-update";
    led = "/sys/class/leds/platform::mute/brightness";
    wpctlTarget = "@DEFAULT_AUDIO_SINK@";
    pactlMuteCmd = "${pactl} get-sink-mute @DEFAULT_SINK@";
    pactlVolCmd = "${pactl} get-sink-volume @DEFAULT_SINK@";
  };

  micmuteUpdate = mkLedUpdater {
    name = "micmute-update";
    led = "/sys/class/leds/platform::micmute/brightness";
    wpctlTarget = "@DEFAULT_AUDIO_SOURCE@";
    pactlMuteCmd = "${pactl} get-source-mute @DEFAULT_SOURCE@";
    pactlVolCmd = "${pactl} get-source-volume @DEFAULT_SOURCE@";
  };

  listener = writeShellScriptBin "pactl-listener" ''
    set -euo pipefail
    OUT_SCRIPT="${muteUpdate}/bin/mute-update"
    MIC_SCRIPT="${micmuteUpdate}/bin/micmute-update"
    "$OUT_SCRIPT"
    "$MIC_SCRIPT"
    LC_ALL=C ${pactl} subscribe | while IFS= read -r line; do
      case "$line" in
        *" on sink "*)          "$OUT_SCRIPT" ;;
        *" on source "*)        "$MIC_SCRIPT" ;;
        *" on server "*)        "$OUT_SCRIPT"; "$MIC_SCRIPT" ;;
        *" on card "*)          "$OUT_SCRIPT"; "$MIC_SCRIPT" ;;
        *" on sink-input "*)    "$OUT_SCRIPT" ;;
        *" on source-output "*) "$MIC_SCRIPT" ;;
      esac
    done
  '';
in
[ listener ]
