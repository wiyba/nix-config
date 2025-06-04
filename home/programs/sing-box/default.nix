{ pkgs, config, lib, ... }:

{
  services.sing-box = {
    enable = true;

    settings = {
      log.level = "info";

      inbounds = [
        {
          type            = "tun";
          tag             = "tun-in";
          interface_name  = "tun0";
          address         = "172.19.0.1/30";   # was inet4_address
          auto_route      = true;
          strict_route    = true;
          stack           = "system";
        }
      ];

      outbounds = [
        { type = "direct"; tag = "direct"; }
        {
          type  = "vless";
          tag   = "proxy";
          server      = { _secret = config.sops.secrets.ip.path; };
          server_port = 8443;
          uuid        = { _secret = config.sops.secrets.uuid.path; };

          tls = {
            enabled     = true;
            server_name = "googletagmanager.com";
            reality = {
              short_id   = { _secret = config.sops.secrets.sid.path; };
              public_key = "0hKXovW8oVrg01lCNbKm0eBp20L_fY6aW2fvdphif3c";
            };
          };
        }
      ];

      route = {
        # подключаем нужные rule-set-ы
        rule_set = [
          {
            type            = "remote";
            tag             = "geosite-ru";
            format          = "binary";
            url             = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/country/geosite-ru.srs";
            update_interval = "24h";
            download_detour = "proxy";
          }
          {
            type            = "remote";
            tag             = "geoip-ru";
            format          = "binary";
            url             = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/country/geoip-ru.srs";
            update_interval = "24h";
            download_detour = "proxy";
          }
        ];

        rules = [
          {
            rule_set = [ "geosite-ru" "geoip-ru" ];
            outbound = "direct";
          }
          {
            domain_suffix = [ "ru" "su" "reddit.com" "www.reddit.com" ];
            outbound      = "direct";
          }
          {
            ip_cidr  = [ "0.0.0.0/0" "::/0" ];
            outbound = "proxy";
          }
        ];
      };
    };
  };
}