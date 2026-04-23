{ pkgs, ... }:
let
  script = pkgs.writeText "health.py" ''
    from http.server import HTTPServer, BaseHTTPRequestHandler
    import json, os, subprocess

    TOKEN = open("/run/secrets/xray-agent").read().strip()
    USAGE = "/var/lib/xray-agent/usage.json"
    XRAY = "${pkgs.xray}/bin/xray"
    SERVER = "127.0.0.1:10085"
    INBOUNDS = [("vless-tcp", "xtls-rprx-vision"), ("vless-xhttp", "")]


    def xray_adu(tag, email, uuid, flow):
        account = {"uuid": uuid}
        if flow:
            account["flow"] = flow
        payload = json.dumps({
            "tag": tag,
            "users": [{"email": email, "account": account}],
        })
        return subprocess.run(
            [XRAY, "api", "adu", f"--server={SERVER}", payload],
            timeout=10,
        ).returncode


    def xray_rmu(tag, email):
        return subprocess.run(
            [XRAY, "api", "rmu", f"--server={SERVER}", tag, email],
            timeout=10,
        ).returncode


    class H(BaseHTTPRequestHandler):
        timeout = 10

        def _auth(self):
            return self.headers.get("Authorization", "") == "Bearer " + TOKEN

        def _reply(self, code, body=b"", ctype="application/json"):
            self.send_response(code)
            if body:
                self.send_header("Content-Type", ctype)
                self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if body:
                self.wfile.write(body)

        def do_GET(self):
            if self.path == "/":
                ok = subprocess.run(
                    ["systemctl", "is-active", "-q", "xray"], timeout=5
                ).returncode == 0
                return self._reply(200 if ok else 503)
            if self.path == "/usage":
                if not self._auth():
                    return self._reply(401)
                try:
                    body = open(USAGE, "rb").read()
                except FileNotFoundError:
                    body = b'{"users":{}}'
                return self._reply(200, body)
            self._reply(404)

        def do_POST(self):
            if self.path != "/user":
                return self._reply(404)
            if not self._auth():
                return self._reply(401)
            length = int(self.headers.get("Content-Length", "0"))
            try:
                req = json.loads(self.rfile.read(length))
                op = req["op"]
                email = req["email"]
                if op == "add":
                    uuid = req["uuid"]
                    for tag, flow in INBOUNDS:
                        xray_adu(tag, email, uuid, flow)
                elif op == "remove":
                    for tag, _ in INBOUNDS:
                        xray_rmu(tag, email)
                else:
                    return self._reply(400)
                return self._reply(200)
            except Exception as e:
                return self._reply(500, str(e).encode(), "text/plain")

        def handle_one_request(self):
            try:
                super().handle_one_request()
            except (ConnectionResetError, TimeoutError, OSError):
                pass

        def log_message(self, *a):
            pass


    HTTPServer(("0.0.0.0", 80), H).serve_forever()
  '';
in
{
  systemd.services.health = {
    description = "health check";
    after = [ "network.target" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      User = "root";
      ExecStart = "${pkgs.python3}/bin/python3 ${script}";
    };
  };
}
