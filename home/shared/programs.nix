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
          settings = {
            "*" = {
              ForwardAgent = false;
              AddKeysToAgent = "240m";
              Compression = false;
              ServerAliveInterval = 0;
              ServerAliveCountMax = 3;
              HashKnownHosts = false;
              UserKnownHostsFile = "~/.ssh/known_hosts";
              ControlMaster = "no";
              ControlPath = "~/.ssh/master-%r@%n:%p";
              ControlPersist = "no";
              IdentityFile = "~/.ssh/ssh.key";
            };
            "helsinki" = {
              HostName = "helsinki.wiyba.org";
              User = "root";
              Port = 2222;
            };
            "moscow" = {
              HostName = "moscow.wiyba.org";
              User = "root";
              Port = 2222;
            };
            "london" = {
              HostName = "london.wiyba.org";
              User = "root";
              Port = 2222;
            };
            "stockholm" = {
              HostName = "stockholm.wiyba.org";
              User = "root";
              Port = 2222;
            };
            "relay" = {
              HostName = "relay.wiyba.org";
              User = "root";
              Port = 2222;
            };
            "home-lan-override" = lib.hm.dag.entryBefore [ "home" ] {
              header = ''Match host home exec "ip -4 -o addr show | grep -qF 192.168.1."'';
              HostName = "192.168.1.1";
            };
            "home" = {
              HostName = "home.wiyba.org";
              User = "wiyba";
              Port = 2222;
            };
            "nest" = {
              HostName = "nest.wiyba.org";
              User = "root";
              Port = 2222;
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
  ../programs/uxplay
  more
]
