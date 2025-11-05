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
(map (name: ./. + "/${name}") (builtins.attrNames (builtins.readDir ./.))) ++ [ more ]
