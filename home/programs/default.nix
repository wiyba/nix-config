let
  more = { config, pkgs, ... }:
  {
    programs = {
      jq.enable = true;
      gpg.enable = true;
      htop = {
        enable = true;
        settings = {
          sort_direction = true;
          sort_key = "PERCENT_CPU";
        };
      };
    };
  };
in
[ 
  ./fastfetch
  ./git
  ./neovim
  ./ssh
  ./zsh
  ./dconf
  ./firefox
  ./kitty
  ./waybar
  ./vscode
  ./spotify
] ++ [ more ]
