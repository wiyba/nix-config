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
      StateDirectory = "mihomo";
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
      log-level: warning
      unified-delay: true
      tcp-concurrent: true
      geodata-mode: true

      dns:
        enable: true
        prefer-h3: true
        default-nameserver:
          - 77.88.8.8
          - 77.88.8.1
        proxy-server-nameserver:
          - https://1.1.1.1/dns-query
          - https://9.9.9.9/dns-query
        nameserver:
          - https://1.1.1.1/dns-query
          - https://9.9.9.9/dns-query

      sniffer:
        enable: true
        parse-pure-ip: true
        override-destination: true
        sniff:
          TLS:
            ports: [443]
          HTTP:
            ports: [80, 8080-8880]
          QUIC:
            ports: [443]

      proxies:
        - name: london
          type: vless
          server: london.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.xray-uuid-relay}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: vk.com
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
          uuid: ${config.sops.placeholder.xray-uuid-relay}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: vk.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-stockholm-key-pub}
            short-id: ${config.sops.placeholder.xray-stockholm-sid}

      rules:
        # optimization
        #- DOMAIN-SUFFIX,nixos.org,london # x2 quota usage
        #- DOMAIN-SUFFIX,cachix.org,london
        - GEOSITE,roblox,stockholm
        - IP-ASN,22697,stockholm,no-resolve
        # geoblocked
        - DOMAIN-SUFFIX,last.fm,london
        - DOMAIN-SUFFIX,audioscrobbler.com,london
        - GEOSITE,youtube,stockholm
        - GEOSITE,lastfm,london
        - GEOSITE,tiktok,london
        - GEOSITE,flibusta,london
        - GEOSITE,rutracker,london
        - GEOSITE,category-ai-!cn,london
        - GEOSITE,figma,london
        - GEOSITE,canva,london
        - GEOSITE,adobe,london
        - GEOSITE,notion,london
        - GEOSITE,atlassian,london
        - GEOSITE,slack,london
        - GEOSITE,spotify,london
        - GEOSITE,netflix,london
        - GEOSITE,twitch,london
        - GEOSITE,deezer,london
        - GEOSITE,jetbrains,london
        - GEOSITE,jetbrains-ai,london
        - GEOSITE,vercel,london
        - GEOSITE,digitalocean,london
        - GEOSITE,dropbox,london
        - GEOSITE,paypal,london
        - GEOSITE,stripe,london
        - GEOSITE,zendesk,london
        - GEOSITE,autodesk,london
        - GEOSITE,patreon,london
        - MATCH,DIRECT
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
