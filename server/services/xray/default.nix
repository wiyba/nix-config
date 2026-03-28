{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  vlessOut = tag: server: {
    protocol = "vless";
    inherit tag;
    settings.vnext = [
      {
        address = server;
        port = 443;
        users = [
          {
            id = config.sops.placeholder.vless-uuid;
            flow = "xtls-rprx-vision";
            encryption = "none";
          }
        ];
      }
    ];
    streamSettings = {
      network = "tcp";
      security = "reality";
      realitySettings = {
        serverName = "yandex.ru";
        fingerprint = "chrome";
        publicKey = "u-2Rr_En_Jx0agQKMG7DlwlLPus2hPLBPMXlOM_-lVU";
        shortId = "4ba9b78acaa91b44";
      };
    };
  };
in
{
  sops.templates.xray-config = {
    content = ''
      {
        "log": { "loglevel": "warning" },
        "inbounds": [{
          "listen": "0.0.0.0",
          "port": 443,
          "protocol": "vless",
          "settings": {
            "clients": ${config.sops.placeholder.xcli-users},
            "decryption": "none"
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
        }],
        "outbounds": ${
          builtins.toJSON (
            if host == "relay" then
              [
                {
                  protocol = "freedom";
                  tag = "direct";
                }
                (vlessOut "london" "london.wiyba.org")
                (vlessOut "moscow" "moscow.wiyba.org")
              ]
            else
              [
                { protocol = "freedom"; }
              ]
          )
        }${
          lib.optionalString (host == "relay") ''
            ,
                    "routing": ${
                      builtins.toJSON {
                        domainStrategy = "AsIs";
                        rules = [
                          {
                            type = "field";
                            domain = [
                              "geosite:flibusta"
                              "geosite:rutracker"
                            ];
                            outboundTag = "london";
                          }
                          {
                            type = "field";
                            ip = [ "geoip:private" ];
                            outboundTag = "direct";
                          }
                          {
                            type = "field";
                            domain = [
                              "geosite:nixos"
                              "geosite:category-ru"
                              "domain:wiyba.org"
                            ];
                            outboundTag = "direct";
                          }
                          {
                            type = "field";
                            domain = [ "geosite:youtube" ];
                            outboundTag = "moscow";
                          }
                          {
                            type = "field";
                            network = "tcp,udp";
                            outboundTag = "london";
                          }
                        ];
                      }
                    }''
        }
      }
    '';
    path = "/etc/xray/config.json";
  };

  systemd.services.xray = {
    description = "xray";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
