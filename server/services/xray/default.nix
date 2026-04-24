{
  config,
  host,
  lib,
  pkgs,
  xrayUsers,
  ...
}:
let
  pollScript = pkgs.writeText "xray-poll.py" ''
    import json, os, subprocess

    STATE = "/var/log/xray/usage.json"
    XRAY = "${pkgs.xray}/bin/xray"
    API = "--server=127.0.0.1:10085"

    def query(reset=False):
        cmd = [XRAY, "api", "statsquery", API, "-pattern=user>>>"]
        if reset:
            cmd.append("-reset")
        raw = subprocess.check_output(cmd, text=True, timeout=15)
        return json.loads(raw).get("stat", [])

    try:
        state = json.load(open(STATE))
    except (FileNotFoundError, ValueError):
        state = {"users": {}}

    users = state.setdefault("users", {})
    for stat in query():
        parts = stat["name"].split(">>>")
        if len(parts) == 4 and parts[0] == "user" and parts[2] == "traffic":
            user = parts[1]
            users[user] = users.get(user, 0) + int(stat.get("value", 0))

    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f)
    os.replace(tmp, STATE)

    query(reset=True)
  '';

  usageScript = pkgs.writeShellScript "usage.sh" ''
    exec ${pkgs.jq}/bin/jq -r '.users | to_entries | sort_by(-.value)[] | "\(.key)\t\(.value)"' /var/log/xray/usage.json |
      ${pkgs.gawk}/bin/awk -F'\t' '{printf "%-20s %7.2f GB\n", $1, $2/1073741824}'
  '';

  adminScript = pkgs.writeText "xray-admin.py" ''
    from http.server import HTTPServer, BaseHTTPRequestHandler
    from urllib.parse import urlparse, parse_qs
    import subprocess, tempfile, os

    TOKEN = open("/run/secrets/xray-admin").read().strip()
    XRAY = "${pkgs.xray}/bin/xray"
    API = "--server=127.0.0.1:10085"
    CMDS = {"adu","rmu","statsquery","stats","statsonline","statsgetallonlineusers",
            "statsonlineiplist","inbounduser","inboundusercount","lsi","lso","sib",
            "restartlogger","adi","rmi","ado","rmo","adrules","rmrules","lsrules"}

    class H(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/":
                rc = subprocess.run(["systemctl","is-active","-q","xray"]).returncode
                self.send_response(200 if rc == 0 else 503); self.end_headers(); return
            if self.path == "/traffic":
                if self.headers.get("Authorization") != f"Bearer {TOKEN}":
                    self.send_response(401); self.end_headers(); return
                try: data = open("/var/log/xray/usage.json","rb").read()
                except FileNotFoundError: data = b'{"users":{}}'
                self.send_response(200)
                self.send_header("Content-Type","application/json")
                self.end_headers(); self.wfile.write(data); return
            self._exec()

        def do_POST(self): self._exec()

        def _exec(self):
            if self.headers.get("Authorization") != f"Bearer {TOKEN}":
                self.send_response(401); self.end_headers(); return
            u = urlparse(self.path)
            cmd = u.path.lstrip("/")
            if cmd not in CMDS:
                self.send_response(404); self.end_headers(); return
            argv = [XRAY, "api", cmd, API]
            for k, vs in parse_qs(u.query).items():
                argv += [f"-{k}={v}" for v in vs]
            n = int(self.headers.get("Content-Length") or 0)
            body = self.rfile.read(n) if n else b""
            tmp = None
            if body:
                if body.lstrip().startswith(b"{"):
                    tmp = tempfile.NamedTemporaryFile(delete=False)
                    tmp.write(body); tmp.close()
                    argv.append(tmp.name)
                else:
                    argv += body.decode().split()
            try:
                r = subprocess.run(argv, capture_output=True, timeout=10)
                self.send_response(200 if r.returncode == 0 else 500)
                self.end_headers()
                self.wfile.write(r.stdout or r.stderr)
            finally:
                if tmp: os.unlink(tmp.name)

        def log_message(self, *a): pass

    HTTPServer(("127.0.0.1", 8888), H).serve_forever()
  '';

  sni =
    {
      relay = "yandex.ru";
      london = "vk.com";
      stockholm = "vk.com";
    }
    .${host};

  client =
    flow: user:
    {
      email = user.name;
      id = config.sops.placeholder."xray-uuid-${user.name}";
    }
    // lib.optionalAttrs (flow != null) { inherit flow; };

  reality = {
    dest = "${sni}:443";
    serverNames = [ sni ];
    privateKey = config.sops.placeholder."xray-${host}-key-priv";
    shortIds = [ config.sops.placeholder."xray-${host}-sid" ];
  };

  xrayConfig = {
    log = {
      loglevel = "warning";
      access = "/var/log/xray/access.log";
      error = "/var/log/xray/error.log";
    };
    stats = { };
    api = {
      tag = "api";
      services = [
        "StatsService"
        "HandlerService"
      ];
    };
    policy.levels."0" = {
      statsUserUplink = true;
      statsUserDownlink = true;
    };
    dns = {
      servers = [
        "https+local://1.1.1.1/dns-query"
        "https+local://9.9.9.9/dns-query"
        "1.1.1.1"
        "9.9.9.9"
      ];
      queryStrategy = "UseIP";
    };
    routing = {
      domainStrategy = "IPIfNonMatch";
      rules = [
        {
          inboundTag = [ "api" ];
          outboundTag = "api";
        }
        {
          ip = [ "geoip:private" ];
          outboundTag = "blocked";
        }
        {
          protocol = [ "bittorrent" ];
          outboundTag = "blocked";
        }
      ];
    };
    inbounds = [
      {
        listen = "127.0.0.1";
        port = 10085;
        protocol = "dokodemo-door";
        settings.address = "127.0.0.1";
        tag = "api";
      }
      {
        listen = "0.0.0.0";
        port = 443;
        protocol = "vless";
        tag = "vless-tcp";
        settings = {
          clients = map (client "xtls-rprx-vision") xrayUsers;
          decryption = "none";
        };
        sniffing = {
          enabled = true;
          destOverride = [
            "http"
            "tls"
            "quic"
          ];
        };
        streamSettings = {
          network = "tcp";
          security = "reality";
          realitySettings = reality;
        };
      }
    ];
    outbounds = [
      (
        if host == "relay" then
          {
            protocol = "socks";
            tag = "out";
            settings.servers = [
              {
                address = "127.0.0.1";
                port = 7891;
              }
            ];
          }
        else
          {
            protocol = "freedom";
            tag = "out";
            settings.domainStrategy = "UseIPv4v6";
          }
      )
      {
        protocol = "blackhole";
        tag = "blocked";
      }
    ];
  };
in
{
  networking.firewall.allowedTCPPorts = [
    443
    8443
  ];

  security.acme.certs."${config.networking.fqdn}".reloadServices = [ "nginx" ];

  services.nginx = {
    enable = true;
    virtualHosts."${config.networking.fqdn}" = {
      onlySSL = true;
      useACMEHost = "${config.networking.fqdn}";
      listen = [
        {
          addr = "0.0.0.0";
          port = 8443;
          ssl = true;
        }
      ];
      locations."/".proxyPass = "http://127.0.0.1:8888";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates.xray-config.path;
  };

  systemd.services.xray = {
    after = [ "sops-nix.service" ];
    restartIfChanged = false;
    serviceConfig.LogsDirectory = "xray";
  };

  systemd.services.xray-poll = {
    description = "xray usage poller";
    after = [ "xray.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 ${pollScript}";
    };
  };

  systemd.timers.xray-poll = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "1min";
      Unit = "xray-poll.service";
    };
  };

  systemd.services.xray-admin = {
    description = "xray admin api";
    after = [ "xray.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      User = "root";
      ExecStart = "${pkgs.python3}/bin/python3 ${adminScript}";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /var/log/xray/usage.sh - - - - ${usageScript}"
  ];

  sops.templates.xray-config = {
    path = "/etc/xray/config.json";
    content = builtins.toJSON xrayConfig;
  };
}
