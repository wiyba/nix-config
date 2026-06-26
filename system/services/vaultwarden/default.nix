{ config, ... }:

{
  sops.secrets.vaultwarden-env = {
    owner = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";
    environmentFile = config.sops.secrets.vaultwarden-env.path;
    config = {
      DOMAIN = "https://vault.wiyba.org";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false;
    };
  };

  services.fail2ban.jails.vaultwarden = {
    filter.Definition.failregex =
      ''^.*(Username or password is incorrect\. Try again|Invalid admin token)\. IP: <ADDR>.*$'';
    settings = {
      backend = "systemd";
      journalmatch = "_SYSTEMD_UNIT=vaultwarden.service";
      port = "80,443";
      maxretry = 5;
      findtime = "10m";
      bantime = "1h";
    };
  };
}
