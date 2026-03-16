{ lib, pkgs, ... }:

let
  userConfig = pkgs.writeText "BurpUserConfig.json" (builtins.toJSON {
    user_options = {
      display = {
        user_interface = {
          font_size = 11;
          look_and_feel = "Light";
        };
        http_message_display = {
          font_name = "Monospaced";
          font_size = 11;
          font_smoothing = true;
          highlight_requests = true;
          highlight_responses = true;
          pretty_print_by_default = true;
        };
      };
    };
  });

  scalingPrefs = pkgs.writeText "burp-prefs.xml" ''
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">
    <map MAP_XML_VERSION="1.0">
      <entry key="free.suite.dpi-aware-enabled" value="false"/>
      <entry key="free.suite.override-default-scaling-options" value="true"/>
      <entry key="free.suite.scale-factor" value="2.0"/>
    </map>
  '';
in
{
  home.packages = [ pkgs.burpsuite ];

  home.activation.burpsuite = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.BurpSuite" "$HOME/.java/.userPrefs/burp"
    for f in .BurpSuite/UserConfigCommunity.json:.java/.userPrefs/burp/prefs.xml; do
      target="$HOME/''${f%%:*}"
      [ -f "$target" ] && continue
      src="${userConfig}"
      [ "$f" != "''${f#*:}" ] && src="${scalingPrefs}"
      cp "$src" "$target" && chmod u+w "$target"
    done
  '';
}
