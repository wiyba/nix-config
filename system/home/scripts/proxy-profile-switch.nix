{ pkgs, ... }:
pkgs.writeShellScriptBin "proxy-profile-switch" ''
  #!/usr/bin/env bash
  API="http://127.0.0.1:9090"

  CURRENT=$(${pkgs.curl}/bin/curl -s "$API/proxies" | ${pkgs.jq}/bin/jq -r '.proxies.PROXY.now')
  PROXIES=(NETHERLANDS RUSSIA)

  for i in "''${!PROXIES[@]}"; do
    if [ "''${PROXIES[$i]}" = "$CURRENT" ]; then
      NEXT="''${PROXIES[$(( (i + 1) % ''${#PROXIES[@]} ))]}"
      ${pkgs.curl}/bin/curl -s -X PUT "$API/proxies/PROXY" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$NEXT\"}" > /dev/null
      echo "Switched to $NEXT"
      exit 0
    fi
  done

  echo "Error: unknown profile $CURRENT"
  exit 1
''
