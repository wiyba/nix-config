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
      log-level: error
      ipv6: false
      external-controller: 127.0.0.1:9090
      geodata-mode: true
      unified-delay: true
      tcp-concurrent: true
      find-process-mode: off

      dns:
        enable: true
        ipv6: false
        enhanced-mode: fake-ip
        fake-ip-range: 198.18.0.1/16
        fake-ip-filter:
          - '*.lan'
          - '*.local'
          - '*.localdomain'
          - '*.invalid'
          - '*.localhost'
          - '*.test'
          - '*.home.arpa'
          - '+.arpa'
          - '+.wiyba.org'
          - 'localhost.*'
          - 'time.*'
          - 'ntp.*'
          - '+.pool.ntp.org'
          - '+.msftncsi.com'
          - '+.msftconnecttest.com'
          - '+.dns.google'
          - '+.stun.*.*'
          - '+.stun.*.*.*'
          - '+.srv.nintendo.net'
          - '+.stun.playstation.net'
          - 'xbox.*.microsoft.com'
          - '*.*.xboxlive.com'
        respect-rules: true
        default-nameserver:
          - 77.88.8.8
          - 77.88.8.1
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
        nameserver-policy:
          "+.themoviedb.org,+.tmdb.org": proxy

      tun:
        enable: true
        stack: gvisor
        auto-route: true
        auto-detect-interface: true
        inet4-address: 198.18.0.1/16
        inet6-address: null
        strict-route: false

      proxies:
        - name: moscow
          type: vless
          server: ${config.sops.placeholder.xray-moscow-ip}
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: vk.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-moscow-key-pub}
            short-id: ${config.sops.placeholder.xray-moscow-sid}

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

        - name: stockholm
          type: vless
          server: stockholm.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: vk.com
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
          uuid: ${config.sops.placeholder.xray-uuid-home}
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
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          ip-version: ipv4
          servername: vk.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-london-key-pub}
            short-id: ${config.sops.placeholder.xray-london-sid}

      rules:
        - GEOSITE,roblox,helsinki
        - IP-ASN,22697,helsinki,no-resolve
        - GEOIP,PRIVATE,DIRECT
        - DOMAIN-SUFFIX,wiyba.org,DIRECT
        - GEOSITE,category-ru,DIRECT
        - MATCH,moscow
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
