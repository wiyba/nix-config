{ config, pkgs, ... }:
{
  systemd.services.mihomo = {
    description = "mihomo";
    after = [ "network.target" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /var/lib/mihomo -f \${CREDENTIALS_DIRECTORY}/config.yaml";
      LoadCredential = "config.yaml:/etc/mihomo/config.yaml";
      AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      StateDirectory = "mihomo";
    };
  };

  sops.templates.mihomo-config = {
    content = ''
      mixed-port: 7890
      mode: rule
      log-level: warning
      external-controller: 127.0.0.1:9090
      dns:
        enable: true
        enhanced-mode: fake-ip
        default-nameserver:
          - 1.1.1.1
          - 8.8.8.8
        nameserver:
          - https://1.1.1.1/dns-query
          - https://8.8.8.8/dns-query

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
          uuid: ${config.sops.placeholder.vless-admin}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: yandex.ru
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: u-2Rr_En_Jx0agQKMG7DlwlLPus2hPLBPMXlOM_-lVU
            short-id: 4ba9b78acaa91b44
        - name: london
          type: vless
          server: london.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.vless-admin}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: yandex.ru
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: u-2Rr_En_Jx0agQKMG7DlwlLPus2hPLBPMXlOM_-lVU
            short-id: 4ba9b78acaa91b44
        - name: stockholm
          type: vless
          server: stockholm.bxteam.org
          port: 3000
          uuid: ${config.sops.placeholder.vless-admin}
          flow: xtls-rprx-vision
          network: tcp
          tls: true
          udp: true
          servername: yandex.ru
          client-fingerprint: firefox
          reality-opts:
            public-key: HZo_AJE11wgeb5SsMBzDi50n1Gp65DNjz-T0x_SfiEw
            short-id: 729c4789bda7d43b

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
        - GEOIP,PRIVATE,DIRECT
        - IP-CIDR6,::/0,LONDON
        - MATCH,RELAY
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
