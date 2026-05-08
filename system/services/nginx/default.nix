{ inputs, pkgs, ... }:
let
  wba-website = inputs.wba-website.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  sops.secrets.acme-env = {
    owner = "acme";
  };
  sops.secrets.cloudflare = {
    owner = "acme";
  };
  sops.secrets."wba-website.env" = { };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "media.wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:8096";
        locations."/".proxyWebsockets = true;
        extraConfig = "client_max_body_size 20M;";
      };

      "music.wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:4533";
      };

      "home.wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:8080";
        locations."/".proxyWebsockets = true;
        locations."/".extraConfig = ''
          proxy_set_header X-Forwarded-Host $http_host;
        '';
      };

      "sub.wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:9999";
      };

      "wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:10000";
      };

      "_" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        default = true;
        locations."/".return = "418";
      };
    };
  };

  systemd.services.wba-website = {
    description = "wba-website";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    wants = [ "network-online.target" ];
    environment = {
      NITRO_PORT = "10000";
      NITRO_HOST = "127.0.0.1";
      NODE_ENV = "production";
    };
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/node ${wba-website}/server/index.mjs";
      EnvironmentFile = "/run/secrets/wba-website.env";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."wiyba.org" = {
      domain = "*.wiyba.org";
      extraDomainNames = [ "wiyba.org" ];
      dnsProvider = "cloudflare";
      environmentFile = "/run/secrets/cloudflare";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
