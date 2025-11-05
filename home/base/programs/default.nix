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
        };
        extraConfig = ''
          Host github.com
            IdentityFile /etc/nixos/home/secrets/keys/multi.key
            IdentitiesOnly yes

          Host vps
            HostName wiyba.org 
            User root
            IdentityFile /etc/nixos/home/secrets/keys/multi.key
            IdentitiesOnly yes

          Host home
            HostName home.wiyba.org
            User root
            IdentityFile /etc/nixos/home/secrets/keys/multi.key
            IdentitiesOnly yes
        '';
      };
    };
  };
in
(map (name: ./. + "/${name}") (builtins.attrNames (builtins.readDir ./.))) ++ [ more ]