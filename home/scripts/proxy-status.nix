{ pkgs, ... }:
pkgs.writeShellScriptBin "proxy-status" ''
  #!/usr/bin/env bash
  
  TIMEOUT=5
  API="http://127.0.0.1:9090"
  SECRET=""
  
  IP_PROXY=$(${pkgs.curl}/bin/curl -4 -s --max-time "$TIMEOUT" ifconfig.me 2>/dev/null)
  PROXY_EXIT=$?
  
  IP_DIRECT=$(${pkgs.curl}/bin/curl -4 -s --max-time "$TIMEOUT" --noproxy '*' ifconfig.me 2>/dev/null)
  DIRECT_EXIT=$?
  
  if [ -n "$SECRET" ]; then
    MODE=$(${pkgs.curl}/bin/curl -s --max-time "$TIMEOUT" -H "Authorization: Bearer $SECRET" "$API/configs" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.mode // "unknown"')
  else
    MODE=$(${pkgs.curl}/bin/curl -s --max-time "$TIMEOUT" "$API/configs" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.mode // "unknown"')
  fi
  
  if [ $PROXY_EXIT -ne 0 ] && [ $DIRECT_EXIT -ne 0 ]; then
    echo '{"text": "", "tooltip": "No connection", "class": "disconnected"}'
    exit 0
  fi
  
  if [ $PROXY_EXIT -ne 0 ] || [ $DIRECT_EXIT -ne 0 ]; then
    echo '{"text": "", "tooltip": "Connection error", "class": "error"}'
    exit 0
  fi
  
  TOOLTIP=$'proxy: '"$IP_PROXY"$'\ndirect: '"$IP_DIRECT"$'\nmode: '"$MODE"
  
  case "$MODE" in
    "direct"|"Direct")
      ICON="󱙱"
      CLASS="direct"
      ;;
    "global"|"Global")
      ICON="󰌾"
      CLASS="global"
      ;;
    "rule"|"Rule")
      ICON="󰿆"
      CLASS="rule"
      ;;
    *)
      ICON=""
      CLASS="unknown"
      ;;
  esac
  
  ${pkgs.jq}/bin/jq -nc \
    --arg text "$ICON" \
    --arg tooltip "$TOOLTIP" \
    --arg class "$CLASS" \
    '{"text": $text, "tooltip": $tooltip, "class": $class}'
''