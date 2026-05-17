{ config, pkgs, ... }:
{
  systemd.services.mihomo = {
    description = "mihomo";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /var/lib/mihomo -f \${CREDENTIALS_DIRECTORY}/config.yaml";
      LoadCredential = "config.yaml:/etc/mihomo/config.yaml";
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      StateDirectory = "mihomo";
    };
  };

  sops.templates.mihomo-config = {
    content = ''
      mixed-port: 7890
      mode: rule
      log-level: warning
      ipv6: false
      external-controller: 127.0.0.1:9090
      geodata-mode: true
      unified-delay: true
      tcp-concurrent: true

      dns:
        enable: true
        ipv6: false
        enhanced-mode: fake-ip
        fake-ip-range: 198.18.0.1/16
        fake-ip-filter:
          - '*.lan'
          - '*.local'
          - '+.arpa'
          - '+.wiyba.org'
          - 'localhost.*'
          - 'time.*'
          - 'pool.ntp.org'
          - '*.msftncsi.com'
          - '*.msftconnecttest.com'
        respect-rules: true
        default-nameserver:
          - 77.88.8.8
          - 77.88.8.1
        proxy-server-nameserver:
          - https://1.1.1.1/dns-query
          - https://8.8.8.8/dns-query
          - https://common.dot.dns.yandex.net/dns-query
        nameserver:
          - https://1.1.1.1/dns-query
          - https://8.8.8.8/dns-query
          - https://common.dot.dns.yandex.net/dns-query

      sniffer:
        enable: true
        force-dns-mapping: true
        parse-pure-ip: true
        override-destination: false
        sniff:
          TLS:
            ports: [443]
          HTTP:
            ports: [80, 8080]
          QUIC:
            ports: [443]

      tun:
        enable: true
        stack: mixed
        auto-route: true
        auto-detect-interface: true
        inet4-address: 198.18.0.1/16
        inet6-address: null
        strict-route: false
        endpoint-independent-nat: true
        udp-timeout: 300
        gso: true
        gso-max-size: 65536

      proxies:
        - name: relay
          type: vless
          server: ${config.sops.placeholder.xray-relay-ip}
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: yandex.ru
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-relay-key-pub}
            short-id: ${config.sops.placeholder.xray-relay-sid}

      rules:
        - GEOIP,PRIVATE,DIRECT
        - DOMAIN-SUFFIX,wiyba.org,DIRECT
        - DOMAIN-SUFFIX,openh264.org,DIRECT
        - GEOSITE,category-ru,DIRECT
        - MATCH,relay
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
