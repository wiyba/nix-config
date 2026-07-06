{ config, pkgs, host, ... }:
let
  node = name: {
    inherit name;
    type = "vless";
    server = "${name}.wiyba.org";
    port = 8443;
    uuid = config.sops.placeholder."xray-uuid-${host}";
    flow = "xtls-rprx-vision";
    network = "tcp";
    tls = true;
    udp = true;
    "ip-version" = "ipv4";
    servername = "${name}.wiyba.org";
    "client-fingerprint" = "chrome";
    alpn = [ "h2" ];
    "reality-opts" = {
      "public-key" = config.sops.placeholder."xray-${name}-key-pub";
      "short-id" = config.sops.placeholder."xray-${name}-sid";
    };
  };

  proxies = {
    helsinki = [ (node "stockholm") (node "home") ];
    stockholm = [ (node "home") ];
    almaty = [ ];
  }.${host};

  rules = {
    helsinki = [
      "DOMAIN-SUFFIX,wiyba.org,DIRECT"
      "GEOSITE,roblox,DIRECT"
      "IP-ASN,22697,DIRECT,no-resolve"
      "GEOSITE,google,DIRECT"
      "GEOSITE,category-ru,home"
      "MATCH,stockholm"
    ];
    stockholm = [
      "DOMAIN-SUFFIX,wiyba.org,DIRECT"
      "GEOSITE,category-ru,home"
      "MATCH,DIRECT"
    ];
    almaty = [
      "MATCH,DIRECT"
    ];
  }.${host};

  mihomoConfig = {
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
    inherit proxies;
    inherit rules;
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
    };
  };

  systemd.services.xray = {
    wants = [ "mihomo.service" ];
    after = [ "mihomo.service" ];
  };

  sops.templates.mihomo-relay-config = {
    content = builtins.toJSON mihomoConfig;
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
