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
      log-level: error
      external-controller: 127.0.0.1:9090
      dns:
        enable: true
        nameserver:
          - 1.1.1.1
          - 8.8.8.8

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
        - name: stockholm
          type: vless
          server: stockholm.wiyba.org
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
        - name: PROXY
          type: select
          proxies:
            - relay
            - london
            - stockholm
            - moscow
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
        - name: MOSCOW
          type: select
          proxies:
            - moscow

      rules:
        - GEOIP,PRIVATE,DIRECT
        - DOMAIN-SUFFIX,ntc.party,LONDON
        - MATCH,RELAY
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };
}
