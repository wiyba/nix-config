{ writeShellScriptBin, hyprctl, jq, ... }:

writeShellScriptBin "csw" ''
  active=$(${hyprctl "hyprctl"} -j monitors | ${jq} --raw-output '.[] | select(.focused==true).specialWorkspace.name | split(":") | if length > 1 then .[1] else "" end')
  if [[ ''${#active} -gt 0 ]]; then
    ${hyprctl "hyprctl"} dispatch togglespecialworkspace "$active"
  fi
''