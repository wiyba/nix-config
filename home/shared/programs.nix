let
  more = { config, pkgs, ... }:
    let
    in {
      programs = {
        # "cat" but better
        bat.enable = true;

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

        # gpg
        gpg.enable = true;

        # obs
        obs-studio = {
          enable = true;
          plugins = [ ];
        };

        # ssh
        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks."*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
          extraConfig = ''
            Host github.com
              IdentityFile /etc/nixos/secrets/keys/multi.key
              IdentitiesOnly yes

            Host vps
              HostName wiyba.org 
              User root
              IdentityFile /etc/nixos/secrets/keys/multi.key
              IdentitiesOnly yes

            Host home
              HostName home.wiyba.org
              User root
              IdentityFile /etc/nixos/secrets/keys/multi.key
              IdentitiesOnly yes
          '';
        };
      };
    };
in
[
  ../programs/firefox
  ../programs/fastfetch
  ../programs/waybar
  ../programs/neovim
  ../programs/dconf
  ../programs/git
  ../programs/zsh
  ../programs/hyprlock
  ../programs/hyprpaper
  ../programs/ncmpcpp
  more
]
