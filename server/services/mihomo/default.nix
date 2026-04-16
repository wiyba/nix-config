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
      unified-delay: true
      tcp-concurrent: true

      dns:
        enable: true
        nameserver:
          - https://1.1.1.1/dns-query
          - https://8.8.8.8/dns-query

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
          servername: fonts.gstatic.com
          client-fingerprint: chrome
          alpn:
            - h2
          reality-opts:
            public-key: ${config.sops.placeholder.xray-london-key-pub}
            short-id: ${config.sops.placeholder.xray-london-sid}

        - name: stockholm
          type: vless
          server: stockholm.bxteam.org
          port: 3000
          uuid: ${config.sops.placeholder.xray-uuid-wiyba}
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
        - MATCH,DIRECT
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
