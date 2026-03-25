{ config, pkgs, lib, host, ... }:
let
  ph = config.sops.placeholder;

  sni = "yandex.ru";
  shortId = "4ba9b78acaa91b44";
  pubKey = "u-2Rr_En_Jx0agQKMG7DlwlLPus2hPLBPMXlOM_-lVU";

  vlessOut = { tag, address, port ? 443 }: {
    protocol = "vless";
    inherit tag;
    settings.vnext = [{
      inherit address port;
      users = [{ id = ph.vless-uuid; flow = "xtls-rprx-vision"; }];
    }];
    streamSettings = {
      network = "tcp";
      security = "reality";
      realitySettings = {
        serverName = sni;
        fingerprint = "firefox";
        publicKey = pubKey;
        inherit shortId;
      };
    };
  };

  hostConfig = {
    stockholm = { };
    london = { };
    moscow = { };
    relay = {
      outbounds = [
        { protocol = "freedom"; tag = "direct"; }
        (vlessOut { tag = "london"; address = "london.wiyba.org"; })
        (vlessOut { tag = "moscow"; address = "moscow.wiyba.org"; })
      ];
      routing = {
        domainStrategy = "AsIs";
        rules = [
          { type = "field"; domain = [ "geosite:flibusta" "geosite:rutracker" ]; outboundTag = "london"; }
          { type = "field"; ip = [ "geoip:private" ]; outboundTag = "direct"; }
          { type = "field"; domain = [ "geosite:nixos" "geosite:category-ru" "domain:wiyba.org" ]; outboundTag = "direct"; }
          { type = "field"; domain = [ "geosite:youtube" ]; outboundTag = "moscow"; }
          { type = "field"; network = "tcp,udp"; outboundTag = "london"; }
        ];
      };
    };
  };

  cfg = hostConfig.${host} or { };
  outbounds = cfg.outbounds or [{ protocol = "freedom"; }];
in
{
  sops.templates.xray-config = {
    content = ''
      {
        "log": {"loglevel": "warning"},
        "inbounds": [{
          "listen": "0.0.0.0",
          "port": 443,
          "protocol": "vless",
          "settings": {
            "clients": ${ph.xcli-users},
            "decryption": "none"
          },
          "streamSettings": {
            "network": "tcp",
            "security": "reality",
            "realitySettings": {
              "dest": "${sni}:443",
              "serverNames": ["${sni}"],
              "privateKey": "${ph.xcli-private-key}",
              "shortIds": ["${shortId}"]
            }
          }
        }],
        "outbounds": ${builtins.toJSON outbounds}${lib.optionalString (cfg ? routing) '',
        "routing": ${builtins.toJSON cfg.routing}''}
      }
    '';
    path = "/etc/xray/config.json";
  };

  systemd.services.xray = {
    description = "xray";
    after = [ "network.target" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
