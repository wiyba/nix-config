{ config
, pkgs
, lib
, inputs
, ...
}:
{
  imports = [ inputs.simple-nixos-mailserver.nixosModules.default ];

  sops.secrets.mail-account-hash = { };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.wiyba.org";
    domains = [ "wiyba.org" ];

    accounts."mail@wiyba.org" = {
      hashedPasswordFile = config.sops.secrets.mail-account-hash.path;
      aliases = [
        "admin@wiyba.org"
        "account@wiyba.org"
        "contact@wiyba.org"
        "wiyba@wiyba.org"
        "abuse@wiyba.org" # RFC 2142
        "security@wiyba.org" # RFC 2142
        "postmaster@wiyba.org" # RFC 5321
      ];

      sieveScript = ''
        require [ "fileinto", "mailbox" ];

        if header :is "X-Spam" "Yes" {
          fileinto "Junk";
          stop;
        }

        if address :is [ "to", "cc" ] [
          "admin@wiyba.org",
          "abuse@wiyba.org",
          "security@wiyba.org",
          "postmaster@wiyba.org"
        ] {
          fileinto :create "Admin";
          stop;
        }

        if address :is [ "to", "cc" ] "account@wiyba.org" {
          fileinto :create "Account";
          stop;
        }
      '';
    };

    x509.useACMEHost = "mail.wiyba.org";
  };

  services.postfix.settings.main = {
    relayhost = [ "[relay.hostup.se]:587" ];
    smtp_tls_security_level = lib.mkForce "encrypt";
  };

  services.rspamd.overrides."greylist.conf".text = "enabled = false;";

  security.acme.certs."mail.wiyba.org" = {
    dnsProvider = "cloudflare";
    environmentFile = "/run/secrets/cloudflare";
    reloadServices = [ "postfix" "dovecot" ];
  };

  services.roundcube = {
    enable = true;
    hostName = "mail.wiyba.org";
    maxAttachmentSize = 25;
    dicts = with pkgs.aspellDicts; [ en ru ];
    extraConfig = ''
      $config['imap_host'] = "ssl://mail.wiyba.org:993";
      $config['smtp_host'] = "ssl://mail.wiyba.org:465";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  services.nginx.virtualHosts."mail.wiyba.org" = {
    enableACME = lib.mkForce false;
    useACMEHost = "mail.wiyba.org";
  };
}
