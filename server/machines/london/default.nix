{ pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
  };

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "london";
    domain = "wiyba.org";

    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "45.154.197.1";
    defaultGateway6 = "2a12:ab46:5344::1";
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "45.154.197.120";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "45.154.197.1";
          prefixLength = 32;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a12:ab46:5344:96::a";
          prefixLength = 64;
        }
      ];
      ipv6.routes = [
        {
          address = "2a12:ab46:5344::1";
          prefixLength = 128;
        }
      ];
    };
    usePredictableInterfaceNames = lib.mkForce true;
  };

  # Health check HTTP server
  systemd.services.hysteria-health = {
    description = "Hysteria Health Check";
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

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            r = subprocess.run(["systemctl", "is-active", "--quiet", "hysteria-server"])
            self.send_response(200 if r.returncode == 0 else 503)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK" if r.returncode == 0 else b"Service Unavailable")
        else:
            self.send_response(404)
            self.end_headers()
    def log_message(self, *args): pass

HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
''}";
    };
  };

  # Nginx with rate limiting for /health endpoint
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=health_limit:1m rate=10r/s;
    '';
    virtualHosts."london.wiyba.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/health" = {
        proxyPass = "http://127.0.0.1:8000";
        extraConfig = ''
          limit_req zone=health_limit burst=5 nodelay;
          limit_req_status 429;
        '';
      };
      locations."/".return = "404";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."london.wiyba.org".reloadServices = [ "hysteria-server" ];
  };

  users.users.nginx.extraGroups = [ "acme" ];

  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "23.11";
}
