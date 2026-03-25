{ pkgs, config, ... }:
{

#  security.acme = {
#    acceptTerms = true;
#    defaults.email = "admin@wiyba.org";
#    certs."${config.networking.fqdn}".reloadServices = [ "hysteria-server" ];
#  };

  systemd.services = {
    hysteria-server = {
      description = "hyst server";
      after = [
        "network.target"
        "sops-nix.service"
        "acme-${config.networking.fqdn}.service"
      ];
      wants = [ "acme-finished-${config.networking.fqdn}.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hysteria}/bin/hysteria server";
        Environment = "HYSTERIA_LOG_LEVEL=error";
        Restart = "always";
        User = "root";
      };
    };
  };

#  services.nginx = {
#    enable = true;
#    recommendedTlsSettings = true;
#    recommendedProxySettings = true;
#    recommendedGzipSettings = true;
#
#    virtualHosts."${config.networking.fqdn}" = {
#      forceSSL = true;
#      enableACME = true;
#      locations."/health".proxyPass = "http://127.0.0.1:8000";
#      locations."/".proxyPass = "http://127.0.0.1:9999";
#    };
#  };
#  users.users.nginx.extraGroups = [ "acme" ];
}
