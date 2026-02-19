{ pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."${config.networking.fqdn}".reloadServices = [ "hysteria-server" ];
  };

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
    hysteria-health = {
      description = "hyst healthcheck";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
        User = "nobody";
        Group = "nogroup";
        ExecStart = "${pkgs.python3}/bin/python3 ${pkgs.writeText "health.py" ''
          from http.server import HTTPServer, BaseHTTPRequestHandler
          import subprocess
          class H(BaseHTTPRequestHandler):
              def do_GET(self):
                  c = 200 if subprocess.run(["systemctl", "is-active", "-q", "hysteria-server"]).returncode == 0 else 503
                  self.send_response(c)
                  self.end_headers()
              def log_message(self, *a): pass
          HTTPServer(("127.0.0.1", 8000), H).serve_forever()
        ''}";
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;

      virtualHosts."${config.networking.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        locations."/health".proxyPass = "http://127.0.0.1:8000";
        locations."/".proxyPass = "http://127.0.0.1:9999";
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
