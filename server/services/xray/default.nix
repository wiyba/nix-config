{
  config,
  host,
  lib,
  ...
}:
let
  users = import ../../../secrets/users.nix;
  hostUsers = lib.filter (u: lib.elem host users.${u}) (lib.attrNames users);

  sni = {
    relay     = "yandex.ru";
    london    = "fonts.gstatic.com";
    stockholm = "fonts.googleapis.com";
  }.${host};

  mkClient = u: withFlow:
    let id = ''"${config.sops.placeholder."xray-uuid-${u}"}"''; in
    if withFlow
    then ''{"email":"${u}","id":${id},"flow":"xtls-rprx-vision"}''
    else ''{"email":"${u}","id":${id}}'';

  clients = withFlow:
    "[" + lib.concatStringsSep "," (map (u: mkClient u withFlow) hostUsers) + "]";

  realityBlock = ''
    "dest": "${sni}:443",
    "serverNames": ["${sni}"],
    "privateKey": "${config.sops.placeholder."xray-${host}-key-priv"}",
    "shortIds": ["${config.sops.placeholder."xray-${host}-sid"}"]
  '';

  sniffing = ''
    "sniffing": {
      "enabled": true,
      "destOverride": ["http", "tls", "quic"]
    }
  '';
in
{
  services.xray = {
    enable = true;
    settingsFile = config.sops.templates.xray-config.path;
  };

  systemd.services.xray = {
    after = [ "sops-nix.service" ];
    restartIfChanged = false;
    serviceConfig.LogsDirectory = "xray";
  };

  sops.templates.xray-config = {
    path = "/etc/xray/config.json";
    content = ''
      {
        "log": {
          "loglevel": "warning",
          "access": "/var/log/xray/access.log",
          "error": "/var/log/xray/error.log"
        },
        "stats": {},
        "api": {
          "tag": "api",
          "services": ["StatsService"]
        },
        "policy": {
          "levels": {
            "0": {
              "statsUserUplink": true,
              "statsUserDownlink": true
            }
          }
        },
        "dns": {
          "servers": [
            "https+local://1.1.1.1/dns-query",
            "https+local://9.9.9.9/dns-query",
            "1.1.1.1",
            "9.9.9.9"
          ],
          "queryStrategy": "UseIP"
        },
        "routing": {
          "domainStrategy": "IPIfNonMatch",
          "rules": [
            { "inboundTag": ["api"], "outboundTag": "api" },
            { "ip": ["geoip:private"], "outboundTag": "blocked" },
            { "protocol": ["bittorrent"], "outboundTag": "blocked" }
          ]
        },
        "inbounds": [
          {
            "listen": "127.0.0.1",
            "port": 10085,
            "protocol": "dokodemo-door",
            "settings": { "address": "127.0.0.1" },
            "tag": "api"
          },
          {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vless",
            "tag": "vless-tcp",
            "settings": {
              "clients": ${clients true},
              "decryption": "none"
            },
            ${sniffing},
            "streamSettings": {
              "network": "tcp",
              "security": "reality",
              "realitySettings": {
                ${realityBlock}
              }
            }
          },
          {
            "listen": "0.0.0.0",
            "port": 8443,
            "protocol": "vless",
            "tag": "vless-xhttp",
            "settings": {
              "clients": ${clients false},
              "decryption": "none"
            },
            ${sniffing},
            "streamSettings": {
              "network": "xhttp",
              "security": "reality",
              "xhttpSettings": {
                "path": "${config.sops.placeholder."xray-${host}-xhttp-path"}"
              },
              "realitySettings": {
                ${realityBlock}
              }
            }
          }
        ],
        "outbounds": [
          ${if host == "relay"
            then ''{"protocol":"socks","tag":"out","settings":{"servers":[{"address":"127.0.0.1","port":7891}]}}''
            else ''{"protocol":"freedom","tag":"out","settings":{"domainStrategy":"UseIPv4v6"}}''},
          { "protocol": "blackhole", "tag": "blocked" }
        ]
      }
    '';
  };
}
