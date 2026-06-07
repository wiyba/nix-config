{ config, pkgs, host, ... }:
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
    content = ''
      socks-port: 7891
      bind-address: 127.0.0.1
      mode: rule
      log-level: error
      ipv6: false
      unified-delay: true
      tcp-concurrent: true
      geodata-mode: true
      find-process-mode: off

      dns:
        enable: true
        ipv6: false
        default-nameserver:
          - 77.88.8.8
          - 1.1.1.1
        proxy-server-nameserver:
          - https://common.dot.dns.yandex.net/dns-query
        nameserver:
          - https://common.dot.dns.yandex.net/dns-query
        fallback:
          - https://1.1.1.1/dns-query
          - https://8.8.8.8/dns-query
        fallback-filter:
          geoip: false
          ipcidr: []

      sniffer:
        enable: true
        force-dns-mapping: true
        parse-pure-ip: true
        override-destination: false
        sniffing-timeout: 100ms
        sniff:
          TLS:
            ports: [443]
          HTTP:
            ports: [80, 8080]
          QUIC:
            ports: [443]

      proxies:
        - name: stockholm
          type: vless
          server: stockholm.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder."xray-uuid-${host}"}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: www.google.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-stockholm-key-pub}
            short-id: ${config.sops.placeholder.xray-stockholm-sid}

        - name: helsinki
          type: vless
          server: helsinki.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder."xray-uuid-${host}"}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: www.google.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-helsinki-key-pub}
            short-id: ${config.sops.placeholder.xray-helsinki-sid}

        - name: london
          type: vless
          server: london.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder."xray-uuid-${host}"}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: www.google.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-london-key-pub}
            short-id: ${config.sops.placeholder.xray-london-sid}

      proxy-groups:
        - name: auto
          type: fallback
          proxies:
            - stockholm
            - helsinki
            - london
          url: 'https://www.gstatic.com/generate_204'
          interval: 60
          lazy: true

      rules:
        - GEOSITE,roblox,helsinki
        - IP-ASN,22697,helsinki,no-resolve
        - GEOSITE,category-ru,DIRECT
        - GEOSITE,youtube,DIRECT
        - GEOSITE,category-ai-!cn,auto
        - MATCH,stockholm
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
