{ config
, pkgs
, lib
, inputs
, ...
}:
{
  imports = [ inputs.simple-nixos-mailserver.nixosModules.default ];

  sops.secrets = {
    mail-account-hash = { };
    smtp2go-password = { };
  };

  sops.templates."smtp2go-sasl" = {
    owner = "postfix";
    content = "[mail-eu.smtp2go.com]:2525 wiyba:${config.sops.placeholder.smtp2go-password}";
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.wiyba.org";
    domains = [ "wiyba.org" ];
    accounts."mail@wiyba.org" = {
      hashedPasswordFile = config.sops.secrets.mail-account-hash.path;
      aliases = [
        "contact@wiyba.org"
        "account@wiyba.org"
        "admin@wiyba.org"
        "postmaster@wiyba.org"
      ];
    };
    x509.useACMEHost = "mail.wiyba.org";
    enableSubmission = true;
    localDnsResolver = true;
  };

  services.rspamd.extraConfig = ''
    options {
      dns {
        nameserver = ["127.0.0.1:53"];
      }
    }
  '';

  services.postfix.settings.main = {
    relayhost = [ "[mail-eu.smtp2go.com]:2525" ];
    smtp_sasl_auth_enable = "yes";
    smtp_sasl_password_maps = "texthash:${config.sops.templates."smtp2go-sasl".path}";
    smtp_sasl_security_options = "noanonymous";
    smtp_tls_security_level = lib.mkForce "encrypt";
  };

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
