{ curl, jq, writeShellScriptBin, ... }:

let
  api = "http://127.0.0.1:9090";
  c = "${curl}/bin/curl";
  j = "${jq}/bin/jq";
  sctl = "/run/current-system/sw/bin/systemctl";

  status = writeShellScriptBin "proxy-status" ''
    if ${c} -s --max-time 1 "${api}/configs" >/dev/null 2>&1; then
      TEXT="󰌾"
      CLASS="active"
    else
      TEXT="󱙱"
      CLASS="inactive"
    fi

    ${j} -nc \
      --arg text "$TEXT" \
      --arg class "$CLASS" \
      '{"text": $text, "class": $class}'
  '';

  toggle = writeShellScriptBin "proxy-toggle" ''
    if ${sctl} is-active --quiet mihomo; then
      sudo ${sctl} stop mihomo
    else
      sudo ${sctl} start mihomo
    fi
  '';
in
[ status toggle ]
