let
  more = { config, pkgs, ... }:
  {
    services = {

    };
  };
in
(map (name: ./. + "/${name}") (builtins.attrNames (builtins.readDir ./.))) ++ [ more ]
