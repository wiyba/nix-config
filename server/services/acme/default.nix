{ config, ... }:
{
  sops.secrets.cloudflare.owner = "acme";

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."${config.networking.fqdn}" = {
      dnsProvider = "cloudflare";
      environmentFile = "/run/secrets/cloudflare";
    };
  };
}
