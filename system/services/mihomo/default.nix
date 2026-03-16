{ config, lib, pkgs, host, ... }:

{
  config = lib.mkMerge [
    # home
    (lib.mkIf (host == "home") {
      systemd.services.mihomo = {
        description = "mihomo Daemon";
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
  enhanced-mode: fake-ip
  nameserver:
    - 1.1.1.1
    - 8.8.8.8
  nameserver-policy:
    "+.themoviedb.org,+.tmdb.org": proxy

tun:
  enable: true
  stack: gvisor
  auto-route: true
  auto-detect-interface: true
  inet4-address: 198.18.0.1/16
  inet6-address: null
  strict-route: true
#  exclude-interface:
#    - enp0s20f0u1

proxies:
  - name: stockholm-hyst
    type: hysteria2
    server: stockholm.wiyba.org
    port: 443
    udp: true
    password: ${config.sops.placeholder.hysteria-auth}
  - name: london-hyst
    type: hysteria2
    server: london.wiyba.org
    port: 443
    password: ${config.sops.placeholder.hysteria-auth}

proxy-groups:
  - name: LONDON
    type: select
    proxies:
      - london-hyst
  - name: STOCKHOLM
    type: select
    proxies:
      - stockholm-hyst

rules:
  - GEOSITE,nixos,DIRECT
  - GEOSITE,steam,DIRECT
  - GEOSITE,category-gov-ru,DIRECT 
  - GEOIP,PRIVATE,DIRECT
  - DOMAIN-SUFFIX,wiyba.org,DIRECT
  - MATCH,STOCKHOLM
        '';
        path = "/etc/mihomo/config.yaml";
        mode = "0600";
      };
    })

    (lib.mkIf (host == "thinkpad") {
      systemd.services.mihomo = {
        description = "mihomo Daemon";
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
  enhanced-mode: fake-ip
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
  - name: home-vless
    type: vless
    server: home.wiyba.org
    port: 9443
    uuid: ${config.sops.placeholder.vless-uuid}
    flow: xtls-rprx-vision
    tls: true
    servername: vk.com
    reality-opts:
      public-key: 8PfX2mydiQ4i3OcdtMMuV5ecwkNsxlGZXNo2bl7OyRc
      short-id: AAAA5555
    udp: true

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - home-vless

rules:
  - MATCH,PROXY
        '';
        path = "/etc/mihomo/config.yaml";
        mode = "0600";
      };
    })
  ];
}
