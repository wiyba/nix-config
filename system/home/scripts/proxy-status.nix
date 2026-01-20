{ pkgs, ... }:
pkgs.writeShellScriptBin "proxy-status" ''
  #!/usr/bin/env bash
  API="http://127.0.0.1:9090"

  MODE=$(${pkgs.curl}/bin/curl -s --max-time 2 "$API/configs" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.mode // "unknown"')
  PROFILE=$(${pkgs.curl}/bin/curl -s --max-time 2 "$API/proxies" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.proxies.PROXY.now // "N/A"')
  IP=$(${pkgs.curl}/bin/curl -4 -s --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")

  TOOLTIP="mode: $MODE"$'\n'"profile: $PROFILE"$'\n'"ip: $IP"

  case "$MODE" in
    "direct"|"Direct")
      TEXT="D"
      CLASS="direct"
      ;;
    "global"|"Global")
      TEXT="G"
      CLASS="global"
      ;;
    "rule"|"Rule")
      TEXT="R"
      CLASS="rule"
      ;;
    *)
      TEXT="?"
      CLASS="unknown"
      ;;
  esac

  ${pkgs.jq}/bin/jq -nc \
    --arg text "$TEXT" \
    --arg tooltip "$TOOLTIP" \
    --arg class "$CLASS" \
    '{"text": $text, "tooltip": $tooltip, "class": $class}'
''
