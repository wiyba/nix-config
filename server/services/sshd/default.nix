{ ... }:

{
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

  networking.nftables.enable = true;

  services.fail2ban = {
    enable = true;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
    jails.sshd.settings = {
      enabled = true;
      port = "2222";
      filter = "sshd";
      findtime = "10m";
      maxretry = 5;
      bantime = "1h";
    };
  };
}
