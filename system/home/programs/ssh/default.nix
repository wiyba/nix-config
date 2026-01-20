{ pkgs, ... }:

{
  programs.ssh = {
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

      Host nl.wiyba.org
        User root
        IdentityFile /home/wiyba/.ssh/multi.key
        IdentitiesOnly yes

      Host uk.wiyba.org
        User root
        IdentityFile /home/wiyba/.ssh/multi.key
        IdentitiesOnly yes

      Host home.wiyba.org
        User root
        IdentityFile /home/wiyba/.ssh/multi.key
        IdentitiesOnly yes
    '';
  };
}
