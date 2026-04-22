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
      external-controller: 127.0.0.1:9090
      geodata-mode: true
      unified-delay: true
      tcp-concurrent: true

      dns:
        enable: true
        prefer-h3: true
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
          - tls://1.1.1.1
          - tls://9.9.9.9
        proxy-server-nameserver:
          - https://1.1.1.1/dns-query
          - https://9.9.9.9/dns-query
        nameserver:
          - https://1.1.1.1/dns-query
          - https://9.9.9.9/dns-query
        nameserver-policy:
          '+.wiyba.org':
            - https://1.1.1.1/dns-query

      sniffer:
        enable: true
        force-dns-mapping: true
        parse-pure-ip: true
        override-destination: true
        sniff:
          TLS:
            ports: [443, 8443]
          HTTP:
            ports: [80, 8080-8880]
          QUIC:
            ports: [443]
        skip-domain:
          - '+.push.apple.com'
          - 'dns.google'

      tun:
        enable: true
        stack: gvisor
        auto-route: true
        auto-detect-interface: true
        inet4-address: 198.18.0.1/16
        inet6-address: null
        strict-route: true

      proxies:
        - name: relay
          type: vless
          server: 158.160.216.59
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: yandex.ru
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-relay-key-pub}
            short-id: ${config.sops.placeholder.xray-relay-sid}
        - name: london
          type: vless
          server: london.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: fonts.gstatic.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-london-key-pub}
            short-id: ${config.sops.placeholder.xray-london-sid}
        - name: stockholm
          type: vless
          server: stockholm.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-home}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: fonts.googleapis.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-stockholm-key-pub}
            short-id: ${config.sops.placeholder.xray-stockholm-sid}

      proxy-groups:
        - name: RELAY
          type: select
          proxies:
            - relay
        - name: LONDON
          type: select
          proxies:
            - london
        - name: STOCKHOLM
          type: select
          proxies:
            - stockholm

      rules:
        - GEOIP,PRIVATE,DIRECT
        - DOMAIN-SUFFIX,nixos.org,LONDON
        - DOMAIN-SUFFIX,cachix.org,LONDON
        - DOMAIN-SUFFIX,wiyba.org,DIRECT
        # geoblocked
        - GEOSITE,youtube,STOCKHOLM
        - GEOSITE,tiktok,LONDON
        - GEOSITE,flibusta,LONDON
        - GEOSITE,rutracker,LONDON
        - GEOSITE,category-ai-!cn,LONDON
        - GEOSITE,figma,LONDON
        - GEOSITE,canva,LONDON
        - GEOSITE,adobe,LONDON
        - GEOSITE,notion,LONDON
        - GEOSITE,atlassian,LONDON
        - GEOSITE,slack,LONDON
        - GEOSITE,spotify,LONDON
        - GEOSITE,netflix,LONDON
        - GEOSITE,deezer,LONDON
        - GEOSITE,jetbrains,LONDON
        - GEOSITE,jetbrains-ai,LONDON
        - GEOSITE,vercel,LONDON
        - GEOSITE,heroku,LONDON
        - GEOSITE,digitalocean,LONDON
        - GEOSITE,dropbox,LONDON
        - GEOSITE,paypal,LONDON
        - GEOSITE,stripe,LONDON
        - GEOSITE,wise,LONDON
        - GEOSITE,zendesk,LONDON
        - GEOSITE,autodesk,LONDON
        - GEOSITE,salesforce,LONDON
        - GEOSITE,godaddy,LONDON
        - GEOSITE,wix,LONDON
        - GEOSITE,patreon,LONDON
        - IP-CIDR6,::/0,LONDON
        - MATCH,RELAY
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
