{ pkgs, ... }:

pkgs.writeShellScriptBin "proxy-switch" ''
  #!/usr/bin/env bash

  API="http://127.0.0.1:9090"
  SECRET=""

  MODES=("rule" "global" "direct")

  if [ -n "$SECRET" ]; then
    CURRENT=$(${pkgs.curl}/bin/curl -s -H "Authorization: Bearer $SECRET" "$API/configs" | ${pkgs.jq}/bin/jq -r '.mode')
  else
    CURRENT=$(${pkgs.curl}/bin/curl -s "$API/configs" | ${pkgs.jq}/bin/jq -r '.mode')
  fi

  for i in "''${!MODES[@]}"; do
    if [ "''${MODES[$i]}" = "$CURRENT" ]; then
      NEXT_INDEX=$(( (i + 1) % ''${#MODES[@]} ))
      NEXT_MODE="''${MODES[$NEXT_INDEX]}"
      break
    fi
  done

  if [ -z "$NEXT_MODE" ]; then
    NEXT_MODE="rule"
  fi

  if [ -n "$SECRET" ]; then
    ${pkgs.curl}/bin/curl -s -X PATCH \
      -H "Authorization: Bearer $SECRET" \
      -H "Content-Type: application/json" \
      -d "{\"mode\":\"$NEXT_MODE\"}" \
      "$API/configs" > /dev/null
  else
    ${pkgs.curl}/bin/curl -s -X PATCH \
      -H "Content-Type: application/json" \
      -d "{\"mode\":\"$NEXT_MODE\"}" \
      "$API/configs" > /dev/null
  fi

  echo "Switched: $CURRENT → $NEXT_MODE"
''
