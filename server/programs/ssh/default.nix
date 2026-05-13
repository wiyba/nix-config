{ ... }:

{
  programs.ssh = {
    extraConfig = ''
      Host *
        ForwardAgent no
        AddKeysToAgent 30m
        Compression no
        ServerAliveInterval 0
        ServerAliveCountMax 3
        HashKnownHosts no
        UserKnownHostsFile ~/.ssh/known_hosts
        ControlMaster no
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist no
        IdentityFile ~/.ssh/multi.key
    '';
  };
}
