{
  services.sing-box = {
    enable = true;

    settings = {
      log.level = "info";

      inbounds = [
        {
          type           = "tun";
          tag            = "tun-in";
          interface_name = "tun0";
          address        = "172.19.0.1/30";
          auto_route     = true;
          strict_route   = true;
          stack          = "system";
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
        rules = [
          { ip_cidr       = ["38.180.230.195/32"];                       outbound = "direct"; }
          { domain_suffix = [ "ru" "su" "reddit.com" "www.reddit.com" ]; outbound = "direct"; }
          { ip_cidr       = [ "0.0.0.0/0" "::/0" ];                      outbound = "proxy"; }
          { outbound      = "proxy";                                     server   = "dns-remote"; }
        ];
      };

      dns = {
        servers = [
          {
            address = "1.1.1.1";
            tag     = "dns-remote";
          }
        ];
      };
    };
  };
}