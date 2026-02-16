let
  more = { pkgs, lib, ... }: {
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
          rounded_corners = true;
          proc_sorting = "cpu direct";
          update_ms = 1000;
        };
      };

      command-not-found.enable = false;

      obs-studio = {
        enable = true;
        plugins = [ ];
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
          addKeysToAgent = "30m";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          identityFile = [ "~/.ssh/multi.key" ];
        };
      };
    };
  };
in
[
  ../programs/dconf
  ../programs/git
  ../programs/firefox
  ../programs/zsh
  ../programs/neovim
  ../programs/fastfetch
  ../programs/vscode
  ../programs/albert
  ../programs/musicpresence
  more
]