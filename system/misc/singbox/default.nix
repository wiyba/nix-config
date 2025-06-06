{ pkgs, config, lib, ... }:

{
  services.sing-box.enable = true;

  services.sing-box.settings = {
    log.level = "info";

    dns = {
      independent_cache = true;
      rules = [
        { outbound = "any"; server = "dns-direct"; }
        { query_type = [ 32 33 ]; server = "dns-block"; }
        { domain_suffix = ".lan"; server = "dns-block"; }
      ];
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
    };

    inbounds = [
      {
        type = "mixed";
        tag = "mixed-in";
        listen = "127.0.0.1";
        listen_port = 2080;
        sniff = true;
        sniff_override_destination = false;
      }
      {
        type = "tun";
        tag = "tun-in";
        interface_name = "neko-tun";
        inet4_address = "172.19.0.1/28";
        auto_route = true;
        strict_route = false;
        stack = "gvisor";
        mtu = 9000;
        sniff = true;
        sniff_override_destination = false;
      }
    ];

    outbounds = [
      {
        type = "vless";
        tag = "proxy";
        server = { _secret = config.sops.secrets.ip.path; };
        server_port = 8443;
        uuid = { _secret = config.sops.secrets.uuid.path; };
        transport = { tcp = {}; };
        tls = {
          enabled = true;
          server_name = "googletagmanager.com";
          utls = { enabled = true; fingerprint = "chrome"; };
          reality = {
            enabled = true;
            public_key = "0hKXovW8oVrg01lCNbKm0eBp20L_fY6aW2fvdphif3c";
            short_id = { _secret = config.sops.secrets.sid.path; };
          };
        };
      }
      { type = "direct"; tag = "direct"; }
      { type = "direct"; tag = "bypass"; }
      { type = "block"; tag = "block"; }
      { type = "dns"; tag = "dns-out"; }
    ];

    route = {
      final = "proxy";
      rule_set = [
        {
          type = "remote";
          tag = "geoip-private";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-private.srs";
          download_detour = "proxy";
        }
        {
          type = "remote";
          tag = "geoip-ru";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
          download_detour = "proxy";
        }
      ];
      rules = [
        { protocol = "dns"; outbound = "dns-out"; }
        { network = "udp"; port = [ 135 137 138 139 5353 ]; outbound = "block"; }
        { ip_cidr = [ "224.0.0.0/3" "ff00::/8" ]; outbound = "block"; }
        { source_ip_cidr = [ "224.0.0.0/3" "ff00::/8" ]; outbound = "block"; }
        { rule_set = "geoip-private"; outbound = "direct"; }
        { rule_set = "geoip-ru"; outbound = "direct"; }
        { domain_regex = ".*\\.ru$"; outbound = "direct"; }
        { domain_suffix = [ "ru" "su" "рф" "xn--p1ai" ]; outbound = "direct"; }
        {
          domain = [
            "captcha.reallyworld.me"
            "2b2t.org"
            "reddit.com" "www.reddit.com"
            "vk.com" "www.vk.com"
            "www.lolz.live" "lolz.live"
            "lenovo.com" "www.lenovo.com"
            "www.roblox.com" "roblox.com" "create.roblox.com"
            "wifiman.com" "www.wifiman.com"
            "abtesting.roblox.com"
            "accountinformation.roblox.com"
            "accountsettings.roblox.com"
            "adconfiguration.roblox.com"
            "ads.roblox.com"
            "apis.roblox.com"
            "assetdelivery.roblox.com"
            "auth.roblox.com"
            "authsite.roblox.com"
            "avatar.roblox.com"
            "badges.roblox.com"
            "billing.roblox.com"
            "captcha.roblox.com"
            "catalog.roblox.com"
            "chat.roblox.com"
            "contacts.roblox.com"
            "develop.roblox.com"
            "economy.roblox.com"
            "economycreatorstats.roblox.com"
            "engagementpayouts.roblox.com"
            "followings.roblox.com"
            "friends.roblox.com"
            "friendsite.roblox.com"
            "games.roblox.com"
            "gameinternationalization.roblox.com"
            "groups.roblox.com"
            "inventory.roblox.com"
            "itemconfiguration.roblox.com"
            "locale.roblox.com"
            "localizationtables.roblox.com"
            "metrics.roblox.com"
            "midas.roblox.com"
            "notifications.roblox.com"
            "premiumfeatures.roblox.com"
            "presence.roblox.com"
            "privatemessages.roblox.com"
            "publish.roblox.com"
            "apis.rcs.roblox.com"
            "thumbnails.roblox.com"
            "trades.roblox.com"
            "translationroles.roblox.com"
            "users.roblox.com"
            "voice.roblox.com"
            "share.roblox.com"
            "clientsettingscdn.roblox.com"
            "www.lzt.market" "lzt.market"
            "account.hoyoverse.com"
            "hoyoverse.com"
          ];
          outbound = "direct";
        }
      ];
    };
  };
}