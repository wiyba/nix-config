{
  writeShellScriptBin,
  hyprland,
  jq,
  ...
}:
let
  hyprctl = "${hyprland}/bin/hyprctl";
in
writeShellScriptBin "close-special-workspace" ''
  active=$(${hyprctl} -j monitors | ${jq}/bin/jq --raw-output '.[] | select(.focused==true).specialWorkspace.name | split(":") | if length > 1 then .[1] else "" end')
  if [[ ''${#active} -gt 0 ]]; then
    ${hyprctl} dispatch togglespecialworkspace "$active"
  fi
''
