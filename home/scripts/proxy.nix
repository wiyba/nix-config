{ curl, jq, writeShellScriptBin, ... }:

let
  api = "http://127.0.0.1:9090";
  c = "${curl}/bin/curl";
  j = "${jq}/bin/jq";

  status = writeShellScriptBin "proxy-status" ''
    MODE=$(${c} -s --max-time 2 "${api}/configs" 2>/dev/null | ${j} -r '.mode // "unknown"')
    PROFILE=$(${c} -s --max-time 2 "${api}/proxies" 2>/dev/null | ${j} -r '.proxies.PROXY.now // "N/A"')
    IP=$(${c} -4 -s --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")

    TOOLTIP="mode: $MODE"$'\n'"profile: $PROFILE"$'\n'"ip: $IP"

    case "$MODE" in
      "direct"|"Direct") TEXT="D"; CLASS="direct" ;;
      "global"|"Global") TEXT="G"; CLASS="global" ;;
      "rule"|"Rule")     TEXT="R"; CLASS="rule" ;;
      *)                 TEXT="?"; CLASS="unknown" ;;
    esac

    ${j} -nc \
      --arg text "$TEXT" \
      --arg tooltip "$TOOLTIP" \
      --arg class "$CLASS" \
      '{"text": $text, "tooltip": $tooltip, "class": $class}'
  '';

  switch = writeShellScriptBin "proxy-switch" ''
    MODES=("rule" "global" "direct")
    CURRENT=$(${c} -s "${api}/configs" | ${j} -r '.mode')

    for i in "''${!MODES[@]}"; do
      if [ "''${MODES[$i]}" = "$CURRENT" ]; then
        NEXT_MODE="''${MODES[$(( (i + 1) % ''${#MODES[@]} ))]}"
        break
      fi
    done

    NEXT_MODE="''${NEXT_MODE:-rule}"

    ${c} -s -X PATCH \
      -H "Content-Type: application/json" \
      -d "{\"mode\":\"$NEXT_MODE\"}" \
      "${api}/configs" > /dev/null

    echo "Switched: $CURRENT → $NEXT_MODE"
  '';

  profileSwitch = writeShellScriptBin "proxy-profile-switch" ''
    CURRENT=$(${c} -s "${api}/proxies" | ${j} -r '.proxies.PROXY.now')
    PROXIES=(stockholm-hyst london-hyst stockholm-vless london-vless)

    for i in "''${!PROXIES[@]}"; do
      if [ "''${PROXIES[$i]}" = "$CURRENT" ]; then
        NEXT="''${PROXIES[$(( (i + 1) % ''${#PROXIES[@]} ))]}"
        ${c} -s -X PUT "${api}/proxies/PROXY" \
          -H "Content-Type: application/json" \
          -d "{\"name\":\"$NEXT\"}" > /dev/null
        echo "Switched to $NEXT"
        exit 0
      fi
    done

    echo "Error: unknown profile $CURRENT"
    exit 1
  '';
in
[ status switch profileSwitch ]
