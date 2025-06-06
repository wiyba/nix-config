{ pkgs, config, lib, ... }:

{
  services.xray.enable = true;

  services.xray.settings = {
    log = { loglevel = "info"; };

    inbounds = [
      {
        listen = "127.0.0.1";
        port = 2080;
        protocol = "mixed";
        sniffing = { enabled = true; };
      }
      {
        protocol = "tun";
        tag = "tun-in";
        interface_name = "tun0";
        inet4_address = "172.19.0.1/28";
        mtu = 1500;
        strict_route = true;
        auto_route = true;
        stack = "system";
      }
    ];

    outbounds = [
      {
        tag = "proxy";
        protocol = "vless";
        settings = {
          vnext = [{
            address = { _secret = config.sops.secrets.ip.path; };
            port    = 8443;
            users   = [{ id = { _secret = config.sops.secrets.uuid.path; }; encryption = "none"; }];
          }];
        };
        streamSettings = {
          network  = "tcp";
          security = "reality";
          realitySettings = {
            serverName  = "googletagmanager.com";
            publicKey   = "0hKXovW8oVrg01lCNbKm0eBp20L_fY6aW2fvdphif3c";
            shortId     = { _secret = config.sops.secrets.sid.path; };
            fingerprint = "chrome";
          };
        };
      }
      { tag = "direct";  protocol = "freedom";    }
      { tag = "block";   protocol = "blackhole"; }
      { tag = "dns-out"; protocol = "dns";       }
    ];

    routing = {
      final = "proxy";
      rules = [
        { type = "field"; protocol = [ "dns" ]; outboundTag = "dns-out"; }
      ];
    };
  };

  systemd.services.xray.serviceConfig = {
    User                  = "root";
    Group                 = "root";
    DynamicUser           = lib.mkForce false;
    CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
    AmbientCapabilities   = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
    NoNewPrivileges       = lib.mkForce false;
    DeviceAllow           = [ "/dev/net/tun rw" ];
  };

  networking.firewall.trustedInterfaces = [ "tun0" ];
}