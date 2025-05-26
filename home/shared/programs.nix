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

      # fuzzy search util
      fzf = {
        enable = true;
        defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
        defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
        fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
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
  ../programs/dconf
  ../programs/git
  ../programs/firefox
  ../programs/fish
  ../programs/khal
  ../programs/md-toc
  ../programs/mimeo
  ../programs/mpv
  ../programs/neofetch
  ../programs/neovim-ide
  ../programs/ngrok
  ../programs/yubikey
  ../programs/zathura
  more
]