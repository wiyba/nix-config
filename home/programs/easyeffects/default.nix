{ lib, pkgs, host, ... }:

let
easyeffectsrc = pkgs.writeText "easyeffectsrc" ''
  [StreamInputs]
  inputDevice=
  visiblePage=pluginsPage

  [StreamOutputs]
  outputDevice=
  plugins=
  visiblePage=pluginsPage

  [Window]
  height=668
  showTrayIcon=false
  width=1251
'';
in {
  # On thinkpad DSP is handled by PipeWire filter-chain (pipewire/default.nix)
  # EasyEffects still available on home for manual use
  services.easyeffects.enable = host != "thinkpad";
  home.activation.easyeffects = lib.mkIf (host != "thinkpad") (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/easyeffects/db"
    if [ ! -f "$HOME/.config/easyeffects/db/easyeffectsrc" ]; then
      cp ${easyeffectsrc} "$HOME/.config/easyeffects/db/easyeffectsrc"
      chmod u+w "$HOME/.config/easyeffects/db/easyeffectsrc"
    fi
  '');
}
