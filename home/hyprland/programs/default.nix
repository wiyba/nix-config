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
  ./vscode
] ++ [ more ]
