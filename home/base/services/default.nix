let
  more = { config, pkgs, ... }:
  {
    services = {

    };
  };
  servicesModules = map (name: ./. + "/${name}") (builtins.attrNames (builtins.readDir ./.));
in
servicesModules ++ [ more ]