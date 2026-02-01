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

  services.openssh = {
    enable = true;
    allowSFTP = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
