{ lib, writeShellScriptBin, hyprctl, jq, ... }:

{
  closeSpecialWorkspace = writeShellScriptBin "close-special-workspace" ''
    active=$(${lib.getExe' hyprctl "hyprctl"} -j monitors | ${lib.getExe jq} --raw-output '.[] | select(.focused==true).specialWorkspace.name | split(":") | if length > 1 then .[1] else "" end')
    if [[ ''${#active} -gt 0 ]]; then
      ${lib.getExe' hyprctl "hyprctl"} dispatch togglespecialworkspace "$active"
    fi
  '';
}
