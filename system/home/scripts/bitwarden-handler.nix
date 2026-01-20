{
  writeShellScriptBin,
  hyprland,
  jq,
  socat,
  ...
}:
let
  hyprctl = "${hyprland}/bin/hyprctl";
in
writeShellScriptBin "bitwarden-handler" ''
  handle_windowtitlev2() {
    local windowaddress="''${1%,*}"
    local windowtitle="''${1#*,}"

    case "$windowtitle" in
      *"(Bitwarden"*"Password Manager) - Bitwarden"*)
        ${hyprctl} --batch \
          "dispatch togglefloating address:0x$windowaddress;" \
          "dispatch resizewindowpixel exact 20% 54%,address:0x$windowaddress;" \
          "dispatch centerwindow"
        ;;
    esac
  }

  handle() {
    local event="''${1%>>*}"
    local data="''${1#*>>}"

    case "$event" in
      windowtitlev2) handle_windowtitlev2 "$data";;
    esac
  }

  ${socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | \
    while read -r line; do 
      handle "$line"
    done
''
