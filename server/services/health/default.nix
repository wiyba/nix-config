{ pkgs, ... }:
{

  systemd.services.health = {
    description = "health check";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      User = "root";
    };
    script = ''
      exec ${pkgs.python3}/bin/python3 ${pkgs.writeText "health.py" ''
        from http.server import HTTPServer, BaseHTTPRequestHandler
        import subprocess
        class H(BaseHTTPRequestHandler):
            timeout = 10
            def do_GET(self):
                ok = subprocess.run(["systemctl", "is-active", "-q", "xray"], timeout=5).returncode == 0
                self.send_response(200 if ok else 503)
                self.end_headers()
            def handle_one_request(self):
                try: super().handle_one_request()
                except (ConnectionResetError, TimeoutError, OSError): pass
            def log_message(self, *a): pass
        HTTPServer(("0.0.0.0", 80), H).serve_forever()
      ''}
    '';
  };
}
