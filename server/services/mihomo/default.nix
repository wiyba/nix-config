{ config, pkgs, ... }:
{
  systemd.services.mihomo = {
    description = "mihomo";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
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
      mixed-port: 7891
      bind-address: 127.0.0.1
      mode: rule
      log-level: warning

      sniffer:
        enable: true
        sniff:
          TLS:
            ports: [443, 8443]
          HTTP:
            ports: [80, 8080-8880]
          QUIC:
            ports: [443]

      dns:
        enable: true
        nameserver:
          - 1.1.1.1
          - 8.8.8.8

      proxies:
        - name: london
          type: vless
          server: london.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.vless-uuid}
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
        - name: moscow
          type: vless
          server: moscow.wiyba.org
          port: 443
          uuid: ${config.sops.placeholder.vless-uuid}
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

      proxy-groups:
        - name: LONDON
          type: select
          proxies:
            - london
        - name: MOSCOW
          type: select
          proxies:
            - moscow

      rules:
        - GEOSITE,youtube,MOSCOW
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
        - MATCH,DIRECT
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
