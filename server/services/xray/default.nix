{ config
, host
, lib
, pkgs
, xrayUsers
, ...
}:
let
  pollScript = pkgs.writeText "xray-poll.py" ''
    import json, os, subprocess, time

    STATE = "/var/log/xray/usage.json"
    XRAY = "${pkgs.xray}/bin/xray"
    API = "--server=127.0.0.1:10085"
    IP_TTL = 172800  # keep iplist entries for 48h after last activity

    def run(*args):
        return subprocess.check_output([XRAY, "api", *args, API], text=True, timeout=15)

    def query(pattern, reset=False):
        cmd = ["statsquery", f"-pattern={pattern}"]
        if reset:
            cmd.append("-reset")
        return json.loads(run(*cmd)).get("stat", [])

    try:
        state = json.load(open(STATE))
    except (FileNotFoundError, ValueError):
        state = {}

    users = state.setdefault("users", {})
    inbounds = state.setdefault("inbounds", {})
    outbounds = state.setdefault("outbounds", {})

    for stat in query("user>>>") + query("inbound>>>") + query("outbound>>>"):
        parts = stat["name"].split(">>>")
        if len(parts) != 4 or parts[2] != "traffic":
            continue
        kind, name, _, direction = parts
        val = int(stat.get("value", 0))
        if kind == "user":
            users[name] = users.get(name, 0) + val
        else:
            target = inbounds if kind == "inbound" else outbounds
            entry = target.setdefault(name, {"uplink": 0, "downlink": 0})
            entry[direction] = entry.get(direction, 0) + val

    query("traffic>>>", reset=True)

    online = {}
    snapshot = {}
    try:
        names = json.loads(run("statsgetallonlineusers")).get("users", []) or []
    except subprocess.CalledProcessError:
        names = []
    for name in names:
        parts = name.split(">>>")
        if len(parts) != 3 or parts[0] != "user" or parts[2] != "online":
            continue
        email = parts[1]
        try:
            r = json.loads(run("statsonline", f"-email={email}"))
            online[email] = int(r.get("stat", {}).get("value", 0))
        except subprocess.CalledProcessError:
            continue
        try:
            ips = json.loads(run("statsonlineiplist", f"-email={email}")).get("ips", {})
            if ips:
                snapshot[email] = ips
        except subprocess.CalledProcessError:
            pass

    iplist = state.get("iplist", {})
    for email, ips in snapshot.items():
        bucket = iplist.setdefault(email, {})
        for ip, ts in ips.items():
            if int(ts) > int(bucket.get(ip, 0)):
                bucket[ip] = int(ts)

    cutoff = int(time.time()) - IP_TTL
    for email in list(iplist):
        iplist[email] = {ip: ts for ip, ts in iplist[email].items() if int(ts) >= cutoff}
        if not iplist[email]:
            del iplist[email]

    state["online"] = online
    state["iplist"] = iplist

    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f)
    os.replace(tmp, STATE)
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
    XRAY, API = "${pkgs.xray}/bin/xray", "--server=127.0.0.1:10085"
    CMDS = {"adu","rmu","statsquery","stats","statsonline","statsgetallonlineusers",
            "statsonlineiplist","inbounduser","inboundusercount","lsi","lso","sib",
            "restartlogger","adi","rmi","ado","rmo","adrules","rmrules","lsrules"}

    class H(BaseHTTPRequestHandler):
        def reply(self, code, body=b""):
            self.send_response(code); self.end_headers(); self.wfile.write(body)
        def auth(self):
            return self.headers.get("Authorization") == f"Bearer {TOKEN}"
        def do_GET(self):
            if self.path == "/":
                rc = subprocess.run(["systemctl","is-active","-q","xray"]).returncode
                return self.reply(200 if rc == 0 else 503)
            if not self.auth(): return self.reply(401)
            if self.path == "/traffic":
                try: data = open("/var/log/xray/usage.json","rb").read()
                except FileNotFoundError: data = b'{"users":{}}'
                return self.reply(200, data)
            self._exec()
        def do_POST(self):
            if not self.auth(): return self.reply(401)
            self._exec()
        def _exec(self):
            u = urlparse(self.path)
            cmd = u.path.lstrip("/")
            if cmd not in CMDS: return self.reply(404)
            argv = [XRAY, "api", cmd, API]
            for k, vs in parse_qs(u.query).items():
                argv += [f"-{k}={v}" for v in vs]
            body = self.rfile.read(int(self.headers.get("Content-Length") or 0))
            tmp = None
            if body:
                if body.lstrip().startswith(b"{"):
                    tmp = tempfile.NamedTemporaryFile(delete=False)
                    tmp.write(body); tmp.close(); argv.append(tmp.name)
                else:
                    argv += body.decode().split()
            try:
                r = subprocess.run(argv, capture_output=True, timeout=10)
                self.reply(200 if r.returncode == 0 else 500, r.stdout or r.stderr)
            finally:
                if tmp: os.unlink(tmp.name)
        def log_message(self, *a): pass

    HTTPServer(("127.0.0.1", 8888), H).serve_forever()
  '';

  sni =
    {
      relay = "yandex.ru";
      moscow = "vk.com";
      london = "vk.com";
      stockholm = "vk.com";
      # helsinki в AS396982 (Google Cloud) — выбираем Google SNI чтобы
      # ASN SNI matched IP ASN (нет mismatch'а для глубокого DPI).
      helsinki = "www.google.com";
    }.${host};

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
      statsUserOnline = true;
    };
    policy.system = {
      statsInboundUplink = true;
      statsInboundDownlink = true;
      statsOutboundUplink = true;
      statsOutboundDownlink = true;
    };
    dns = {
      servers = [ "localhost" ];
      queryStrategy = if lib.elem host [ "relay" "moscow" ] then "UseIPv4" else "UseIP";
    };
    routing = {
      domainStrategy = "AsIs";
      rules = [
        {
          inboundTag = [ "api" ];
          outboundTag = "api";
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
        sniffing.enabled = false;
        streamSettings = {
          network = "tcp";
          security = "reality";
          realitySettings = reality;
        };
      }
    ];
    outbounds = [
      (
        if lib.elem host [ "relay" "moscow" ] then
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
            settings.domainStrategy = "UseIPv6v4";
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

  services.logrotate.settings.xray = {
    files = [
      "/var/log/xray/access.log"
      "/var/log/xray/error.log"
    ];
    frequency = "daily";
    rotate = 7;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    create = "0600 nobody nogroup";
    postrotate = "${pkgs.systemd}/bin/systemctl kill -s USR1 xray.service || true";
  };

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
      OnBootSec = "10s";
      OnUnitActiveSec = "10s";
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
