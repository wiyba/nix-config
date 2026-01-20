{ pkgs, ... }:
let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  mute-update = "${pkgs.callPackage ./mute-update.nix { }}/bin/mute-update";
  micmute-update = "${pkgs.callPackage ./micmute-update.nix { }}/bin/micmute-update";
in
pkgs.writeShellScriptBin "pactl-listner" ''
  #!/bin/sh
  set -euo pipefail
  OUT_SCRIPT="${mute-update}"
  MIC_SCRIPT="${micmute-update}"
  "$OUT_SCRIPT"
  "$MIC_SCRIPT"
  LC_ALL=C ${pactl} subscribe | while IFS= read -r line; do
    case "$line" in
    *" on sink "*) "$OUT_SCRIPT" ;;
    *" on source "*) "$MIC_SCRIPT" ;;
    *" on server "*)
      "$OUT_SCRIPT"
      "$MIC_SCRIPT"
      ;;
    *" on card "*)
      "$OUT_SCRIPT"
      "$MIC_SCRIPT"
      ;;
    *" on sink-input "*) "$OUT_SCRIPT" ;;
    *" on source-output "*) "$MIC_SCRIPT" ;;
    esac
  done
''
