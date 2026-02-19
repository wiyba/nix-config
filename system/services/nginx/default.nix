{ ... }:

{
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

      "hyst.wiyba.org" = {
        forceSSL = true;
        useACMEHost = "wiyba.org";
        locations."/".proxyPass = "http://127.0.0.1:8888";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."wiyba.org" = {
      domain = "*.wiyba.org";
      dnsProvider = "cloudflare";
      environmentFile = "/run/secrets/cloudflare";
      reloadServices = [ "hysteria-server" ];
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
