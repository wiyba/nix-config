{ pkgs, config, ... }:

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

  systemd.services.normalize-ssh-comment = {
    description = "normalize ssh host key comment to root@${config.networking.fqdnOrHostName}";
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      DESIRED="root@${config.networking.fqdnOrHostName}"
      for KEY in /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_rsa_key; do
        [ -f "$KEY.pub" ] || continue
        CURRENT=$(${pkgs.coreutils}/bin/cut -d ' ' -f 3- < "$KEY.pub")
        if [ "$CURRENT" != "$DESIRED" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -c -C "$DESIRED" -f "$KEY" >/dev/null
        fi
      done
    '';
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
