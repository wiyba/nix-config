{
  config,
  host,
  ...
}:
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
        "routing": {
          "rules": [
            { "inboundTag": ["api"], "outboundTag": "api" }
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
            "settings": {
              "clients": ${config.sops.placeholder.xcli-users},
              "decryption": "none"
            },
            "sniffing": {
              "enabled": true,
              "destOverride": ["http", "tls", "quic"]
            },
            "streamSettings": {
              "network": "tcp",
              "security": "reality",
              "realitySettings": {
                "dest": "yandex.ru:443",
                "serverNames": ["yandex.ru"],
                "privateKey": "${config.sops.placeholder.xcli-private-key}",
                "shortIds": ["4ba9b78acaa91b44"]
              }
            }
          }
        ],
        "outbounds": [${
          if host == "relay"
          then ''{"protocol": "socks", "settings": {"servers": [{"address": "127.0.0.1", "port": 7891}]}}''
          else ''{"protocol": "freedom"}''
        }]
      }
    '';
    path = "/etc/xray/config.json";
  };
}
