let
  more = { config, pkgs, ... }:
  {
    programs = {
    };
  };
in
[
  ./dconf
  ./firefox
  ./kitty
  ./waybar
] ++ [ more ]
