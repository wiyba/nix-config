{ pkgs, config, ... }:

{
  services.sing-box = {
    enable = true;

    settings = {
      log.level = "info";

      inbounds = [
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "tun0";
          inet4_address = "172.19.0.1/30";
          auto_route = true;
          strict_route = true;
          stack = "system";
        }
      ];

      outbounds = [
        { type = "direct"; tag = "direct"; }
        {
          type = "vless";
          tag = "proxy";
          server = {
            _secret = config.sops.secrets.ip.path;
          };
          server_port = 8443;
          uuid = {
            _secret = config.sops.secrets.uuid.path;
          };
          transport.type = "tcp";

          tls = {
            enabled = true;
            server_name = "googletagmanager.com";
            reality = {
              short_id = {
                _secret = config.sops.secrets.sid.path;
              };
              public_key = "0hKXovW8oVrg01lCNbKm0eBp20L_fY6aW2fvdphif3c";
            };
          };
        }
      ];

      route = {
        geoip.path = "${pkgs.sing-geoip}/share/sing-box/geoip.db";
        geosite.path = "${pkgs.sing-geosite}/share/sing-box/geosite.db";

        rules = [
          { geoip = [ "ru" ]; geosite = [ "ru" ]; outbound = "direct"; }
          { ip_cidr = [ "0.0.0.0/0" "::/0" ]; outbound = "proxy"; }
        ];
      };
    };
  };
}