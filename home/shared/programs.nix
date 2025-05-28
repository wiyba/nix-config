let
  more = { pkgs, ... }: {
    programs = {
      # "cat" but better
      bat.enable = true;

      # auto .envrc variables
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # htop
      htop = {
        enable = true;
        settings = {
          sort_direction = true;
          sort_key = "PERCENT_CPU";
        };
      };

      # json parser
      jq.enable = true;

      # obs
      obs-studio = {
        enable = true;
        plugins = [ ];
      };

      # ssh
      ssh.enable = true;
    };
  };
in
[
  ../programs/fastfetch
  ../programs/waybar
  ../programs/dconf
  ../programs/git
  ../programs/zsh
  ../programs/hyprlock
  ../programs/hyprpaper
  more
]