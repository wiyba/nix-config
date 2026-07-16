{ config, host, xrayUsers, ... }:
let
  settings = {
    log = {
      loglevel = "warning";
      access = "/var/log/xray/access.log";
      error = "/var/log/xray/error.log";
    };
    stats = { };
    api = {
      tag = "api";
      services = [ "StatsService" "HandlerService" ];
    };
    policy = {
      levels."0" = {
        statsUserUplink = true;
        statsUserDownlink = true;
        statsUserOnline = true;
      };
      system = {
        statsInboundUplink = true;
        statsInboundDownlink = true;
        statsOutboundUplink = true;
        statsOutboundDownlink = true;
      };
    };
    dns = {
      servers = [ "localhost" ];
      queryStrategy = "UseIP";
    };
    routing.rules = [
      { inboundTag = [ "api" ]; outboundTag = "api"; }
      { protocol = [ "bittorrent" ]; outboundTag = "blocked"; }
    ];
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
        port = 8443;
        protocol = "vless";
        tag = "vless-tcp";
        settings = {
          clients = map
            (u: {
              email = u.name;
              id = config.sops.placeholder."xray-uuid-${u.name}";
              flow = "xtls-rprx-vision";
            })
            xrayUsers;
          decryption = "none";
        };
        sniffing.enabled = false;
        streamSettings = {
          network = "tcp";
          security = "reality";
          realitySettings = {
            dest = "127.0.0.1:443";
            serverNames = [ config.networking.fqdn ];
            privateKey = config.sops.placeholder."xray-${host}-key-priv";
            shortIds = [ config.sops.placeholder."xray-${host}-sid" ];
          };
        };
      }
    ];
    outbounds = [
      {
        protocol = "socks";
        tag = "out";
        settings.servers = [{ address = "127.0.0.1"; port = 7891; }];
      }
      {
        protocol = "blackhole";
        tag = "blocked";
      }
    ];
  };
in
{
  networking.firewall.allowedTCPPorts = [ 8443 ];

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates.xray.path;
  };

  systemd.services.xray = {
    after = [
      "sops-nix.service"
      "mihomo.service"
    ];
    wants = [ "mihomo.service" ];
    restartIfChanged = false;
    serviceConfig.LogsDirectory = "xray";
  };

  sops.secrets."xray-${host}-key-priv".key = "xray/${host}/key_priv";

  sops.templates.xray = {
    path = "/etc/xray/config.json";
    content = builtins.toJSON settings;
  };

  services.logrotate.settings.xray = {
    files = [
      "/var/log/xray/access.log"
      "/var/log/xray/error.log"
    ];
    frequency = "daily";
    rotate = 7;
    compress = true;
    missingok = true;
    notifempty = true;
    copytruncate = true;
  };
}
