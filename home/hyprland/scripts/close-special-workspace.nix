{ writeShellScriptBin, hyprland, jq, ... }:
let
  hyprctl = "${hyprland}/bin/hyprctl";
  jq = "${jq}/bin/jq";
in
writeShellScriptBin "csw" ''
  active=$(${hyprctl} -j monitors | ${jq} --raw-output '.[] | select(.focused==true).specialWorkspace.name | split(":") | if length > 1 then .[1] else "" end')
  if [[ ''${#active} -gt 0 ]]; then
    ${hyprctl} dispatch togglespecialworkspace "$active"
  fi
''