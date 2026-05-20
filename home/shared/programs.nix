let
  more =
    { pkgs, lib, ... }:
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

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "*" = {
              forwardAgent = false;
              addKeysToAgent = "240m";
              compression = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "~/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "london" = {
              hostname = "london.wiyba.org";
              user = "root";
              port = 2222;
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "stockholm" = {
              hostname = "stockholm.wiyba.org";
              user = "root";
              port = 2222;
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "relay" = {
              hostname = "relay.wiyba.org";
              user = "root";
              port = 2222;
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "home-lan-override" = lib.hm.dag.entryBefore [ "home" ] {
              match = ''host home exec "ip -4 route get 192.168.1.1 2>/dev/null | grep -q dev"'';
              hostname = "192.168.1.1";
            };
            "home" = {
              hostname = "home.wiyba.org";
              user = "wiyba";
              port = 2222;
              identityFile = [ "~/.ssh/ssh.key" ];
            };
            "nest" = {
              hostname = "nest.wiyba.org";
              user = "root";
              port = 2222;
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
  ../programs/musicpresence
  ../programs/zed
  ../programs/discord-canary
  ../programs/uxplay
  more
]
