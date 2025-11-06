let
  more = { config, pkgs, ... }:
  {
    services = {
      gnome-keyring = {
        enable = true;
        components = [ "ssh" "secrets" ];
      };
    };
  };
in
[ more ]
