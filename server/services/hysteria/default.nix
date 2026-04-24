{ config, pkgs, ... }:
let
  hysteriaConfig = {
    listen = ":443";

    tls = {
      cert = "/var/lib/acme/${config.networking.fqdn}/fullchain.pem";
      key = "/var/lib/acme/${config.networking.fqdn}/key.pem";
    };

    trafficStats = {
      listen = "127.0.0.1:9999";
      secret = config.sops.placeholder.hysteria-secret;
    };

    auth = {
      type = "http";
      http.url = "https://hyst.wiyba.org/auth";
    };

    acl.inline = [
      "reject(127.0.0.0/8)"
      "reject(10.0.0.0/8)"
      "reject(172.16.0.0/12)"
      "reject(192.168.0.0/16)"
    ];

    masquerade = {
      type = "proxy";
      proxy = {
        url = "https://fonts.gstatic.com/";
        rewriteHost = true;
      };
    };
  };
in
{
  networking.firewall = {
    allowedTCPPorts = [ 9443 ];
    allowedUDPPorts = [ 443 ];
  };

  security.acme.certs."${config.networking.fqdn}".reloadServices = [
    "hysteria-server"
    "nginx"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."${config.networking.fqdn}" = {
      useACMEHost = "${config.networking.fqdn}";
      listen = [{ addr = "0.0.0.0"; port = 9443; ssl = true; }];
      locations."/".proxyPass = "http://127.0.0.1:9999";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  sops.templates.hysteria-config = {
    path = "/etc/hysteria/config.yaml";
    mode = "0444";
    content = builtins.toJSON hysteriaConfig;
  };

  systemd.services.hysteria-server = {
    description = "hyst server";
    after = [
      "network.target"
      "sops-nix.service"
      "acme-${config.networking.fqdn}.service"
    ];
    wants = [ "acme-finished-${config.networking.fqdn}.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c ${config.sops.templates.hysteria-config.path}";
      Environment = "HYSTERIA_LOG_LEVEL=error";
      Restart = "always";
      User = "root";
    };
  };
}
