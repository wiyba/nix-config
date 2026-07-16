{ config, lib, pkgs, host, ... }:
let
  node = name: {
    inherit name;
    type = "vless";
    server = "${name}.wiyba.org";
    servername = "${name}.wiyba.org";
    port = 8443;
    uuid = config.sops.placeholder."xray-uuid-${cfg.uuid or host}";
    flow = "xtls-rprx-vision";
    network = "tcp";
    tls = true;
    udp = true;
    "ip-version" = "ipv4";
    "client-fingerprint" = "chrome";
    alpn = [ "h2" ];
    "reality-opts" = {
      "public-key" = config.sops.placeholder."xray-${name}-key-pub";
      "short-id" = config.sops.placeholder."xray-${name}-sid";
    };
  };

  hosts = {
    home = {
      tun = true;
      proxies = [ (node "stockholm") ];
      rules = [
        "GEOIP,PRIVATE,DIRECT"
        "DOMAIN-SUFFIX,wiyba.org,DIRECT"

        "GEOSITE,category-game-platforms-download,DIRECT"
        "GEOSITE,sony,DIRECT"
        "GEOSITE,steam,DIRECT"
        "GEOSITE,category-ru,DIRECT"

        "IP-ASN,22697,stockholm,no-resolve"
        "GEOSITE,roblox,stockholm"
        "MATCH,stockholm"
      ];
    };
    thinkpad = {
      tun = true;
      uuid = "home";
      proxies = [ (node "home") ];
      rules = [
        "GEOIP,PRIVATE,DIRECT"
        "MATCH,home"
      ];
    };
    stockholm = {
      tun = false;
      proxies = [ (node "home") ];
      rules = [
        "GEOSITE,category-ru,home"
        "MATCH,DIRECT"
      ];
    };
    almaty = {
      tun = false;
      proxies = [ ];
      rules = [ "MATCH,DIRECT" ];
    };
  };

  cfg = hosts.${host};

  settings = {
    "socks-port" = 7891;
    "bind-address" = "127.0.0.1";
    mode = "rule";
    "log-level" = "error";
    ipv6 = false;
    "unified-delay" = true;
    "tcp-concurrent" = true;
    "geodata-mode" = true;
    "find-process-mode" = "off";
    dns = {
      enable = true;
      ipv6 = false;
      "default-nameserver" = [ "77.88.8.8" "1.1.1.1" ];
      "proxy-server-nameserver" = [ "https://common.dot.dns.yandex.net/dns-query" ];
      nameserver = [ "https://common.dot.dns.yandex.net/dns-query" ];
      fallback = [ "https://1.1.1.1/dns-query" "https://8.8.8.8/dns-query" ];
      "fallback-filter" = {
        geoip = false;
        ipcidr = [ "127.0.0.0/8" "0.0.0.0/8" ];
      };
    } // lib.optionalAttrs cfg.tun {
      "enhanced-mode" = "fake-ip";
      "fake-ip-range" = "198.18.0.1/16";
      "respect-rules" = true;
      "fake-ip-filter" = [
        "*.lan"
        "*.local"
        "*.localdomain"
        "*.invalid"
        "*.localhost"
        "*.test"
        "*.home.arpa"
        "+.arpa"
        "+.wiyba.org"
        "localhost.*"
        "time.*"
        "ntp.*"
        "+.pool.ntp.org"
        "+.msftncsi.com"
        "+.msftconnecttest.com"
        "+.dns.google"
        "+.stun.*.*"
        "+.stun.*.*.*"
        "+.srv.nintendo.net"
        "+.stun.playstation.net"
        "xbox.*.microsoft.com"
        "*.*.xboxlive.com"
      ];
    };
    sniffer = {
      enable = true;
      "force-dns-mapping" = true;
      "parse-pure-ip" = true;
      "override-destination" = false;
      "sniffing-timeout" = "100ms";
      sniff = {
        TLS.ports = [ 443 ];
        HTTP.ports = [ 80 8080 ];
        QUIC.ports = [ 443 ];
      };
    };
    inherit (cfg) proxies rules;
  } // lib.optionalAttrs cfg.tun {
    "mixed-port" = 7890;
    "external-controller" = "127.0.0.1:9090";
    tun = {
      enable = true;
      stack = "gvisor";
      "auto-route" = true;
      "auto-detect-interface" = true;
      "inet4-address" = "198.18.0.1/16";
      "strict-route" = false;
    };
  };
in
{
  systemd.services.mihomo = {
    description = "mihomo";
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/ln -sfn ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /var/lib/mihomo/GeoSite.dat";
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /var/lib/mihomo -f \${CREDENTIALS_DIRECTORY}/config.yaml";
      LoadCredential = "config.yaml:/etc/mihomo/config.yaml";
      StateDirectory = "mihomo";
      Restart = "on-failure";
      RestartSec = "5s";
    } // lib.optionalAttrs cfg.tun {
      AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    };
  };

  sops.templates.mihomo = {
    content = builtins.toJSON settings;
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
