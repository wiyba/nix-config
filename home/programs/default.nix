let
  more = { config, pkgs, ... }:
  {
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
          identityFile = [ "~/.ssh/multi.key" ];
        };
        extraConfig = ''
          Host github.com
            IdentityFile /home/wiyba/.ssh/multi.key
            IdentitiesOnly yes

          Host vps
            HostName wiyba.org 
            User root
            IdentityFile /home/wiyba/.ssh/multi.key
            IdentitiesOnly yes

          Host home
            HostName home.wiyba.org
            User root
            IdentityFile /home/wiyba/.ssh/multi.key
            IdentitiesOnly yes
        '';
      };
    };
  };
in
[ 
  ./fastfetch
  ./git
  ./neovim
  ./zsh
  ./dconf
  ./firefox
  ./kitty
  ./waybar
  ./vscode
] ++ [ more ]
