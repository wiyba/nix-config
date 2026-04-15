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
          plugins = [ ];
        };

	mangohud.enable = true;

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "*" = {
              forwardAgent = false;
              addKeysToAgent = "120m";
              compression = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "~/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
              identityFile = [ "~/.ssh/ssh.key" ];
              port = 2222;
            };
            "london" = {
              hostname = "london.wiyba.org";
              user = "root";
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "moscow" = {
              hostname = "moscow.wiyba.org";
              user = "root";
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "relay" = {
              hostname = "relay.wiyba.org";
              user = "root";
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "home" = {
              hostname = "home.wiyba.org";
              user = "wiyba";
              identityFile = [ "~/.ssh/ssh.key" ];
            };
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
  ../programs/zed
  ../programs/burpsuite
  more
]
