let
  more = { config, pkgs, ... }:
  {
    programs = {
    };
  };
in
(map (name: ./. + "/${name}") (builtins.attrNames (builtins.readDir ./.))) ++ [ more ]