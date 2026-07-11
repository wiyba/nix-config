let
  more =
    { pkgs, ... }:
    {
      programs = {
        bat.enable = true;

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        btop = {
          enable = true;
          package = pkgs.btop.override {
            rocmSupport = true;
          };
          settings = {
            color_theme = "gruvbox_material_dark";
            theme_background = false;
            rounded_corners = true;
            proc_sorting = "cpu direct";
            update_ms = 1000;
          };
        };

        command-not-found.enable = false;

        obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-pipewire-audio-capture
          ];
        };

        mangohud.enable = true;
      };
    };
in
[
  ../programs/aerc
  # ../programs/burpsuite
  ../programs/claude
  ../programs/dconf
  # ../programs/easyeffects
  # ../programs/fastfetch
  ../programs/firefox
  # ../programs/foot
  ../programs/git
  ../programs/musicpresence
  ../programs/neovim
  ../programs/ssh
  # ../programs/vscode
  ../programs/uxplay
  ../programs/zed
  ../programs/zsh
  more
]
