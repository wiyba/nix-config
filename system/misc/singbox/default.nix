{ pkgs, config, lib, ... }:

{
  services.sing-box.enable = true;

  services.sing-box.settings = {
    log.level = "info";

    dns = {
      independent_cache = true;
      servers = [
        {
          address = "https://1.1.1.1/dns-query";
          address_resolver = "dns-local";
          detour = "proxy";
          tag = "dns-remote";
        }
        {
          address = "https://1.1.1.1/dns-query";
          address_resolver = "dns-local";
          detour = "direct";
          tag = "dns-direct";
        }
        { address = "rcode://success"; tag = "dns-block"; }
        { address = "local"; detour = "direct"; tag = "dns-local"; }
      ];
      rules = [
        { outbound = "any"; server = "dns-direct"; }
        { query_type = [ 32 33 ]; server = "dns-block"; }
        { domain_suffix = ".lan"; server = "dns-block"; }
      ];
    };

    inbounds = [
      {
        tag            = "mixed-in";
        type           = "mixed";
        listen         = "127.0.0.1";
        listen_port    = 2080;
        sniff          = true;
      }
      {
        tag                        = "tun-in";
        type                       = "tun";
        interface_name             = "tun0";
        address                    = [ "172.19.0.1/28" ];
        mtu                        = 1500;
        auto_route                 = true;
        strict_route               = true;
        stack                      = "system";
        endpoint_independent_nat   = true;
      }
    ];

    outbounds = [
      {
        tag         = "proxy";
        type        = "vless";
        server      = { _secret = config.sops.secrets.ip.path; };
        server_port = 8443;
        uuid        = { _secret = config.sops.secrets.uuid.path; };
        transport   = { tcp = {}; };
        tls = {
          enabled     = true;
          server_name = "googletagmanager.com";
          utls        = { enabled = true; fingerprint = "chrome"; };
          reality     = {
            enabled     = true;
            public_key  = "0hKXovW8oVrg01lCNbKm0eBp20L_fY6aW2fvdphif3c";
            short_id    = { _secret = config.sops.secrets.sid.path; };
          };
        };
      }
      { tag = "direct";  type = "direct"; }
      { tag = "block";   type = "block";  }
      { tag = "dns-out"; type = "dns";    }
    ];

    route = {
      final = "proxy";
      rules = [
        { protocol = "dns"; outbound = "dns-out"; }
      ];
    };
  };
}