{ config, ... }:
{
  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets.hysteria-auth = { };
    secrets.vless-auth = { };
    secrets.github_token = { };

    templates.mihomo-config = {
    templates.mihomo-config = {
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
  mtu: 9000
  strict-route: true

proxies:
  - name: stockholm-hyst
    type: hysteria2
    server: stockholm.wiyba.org
    port: 443
    udp: true
    password: ${config.sops.placeholder.hysteria-auth}
    skip-cert-verify: true
  - name: london-hyst
    type: hysteria2
    server: london.wiyba.org
    port: 443
    password: ${config.sops.placeholder.hysteria-auth}
    skip-cert-verify: true
  - name: stockholm-vless
    type: vless
    server: stockholm.wiyba.org
    port: 443
    uuid: ${config.sops.placeholder.vless-auth}
    network: tcp
    tls: true
    udp: true
    flow: xtls-rprx-vision
    servername: www.microsoft.com
    reality-opts:
      public-key: xrwkG2xAfrB_JU0tLX4GDfW_rhkuSsJyY39vNF0VdCY
  - name: london-vless
    type: vless
    server: london.wiyba.org
    port: 443
    uuid: ${config.sops.placeholder.vless-auth}
    network: tcp
    tls: true
    udp: true
    flow: xtls-rprx-vision
    servername: www.microsoft.com
    reality-opts:
      public-key: xrwkG2xAfrB_JU0tLX4GDfW_rhkuSsJyY39vNF0VdCY


proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - stockholm-hyst
      - london-hyst
      - stockholm-vless
      - london-vless

rules:
# direct overrides
  - IP-CIDR,128.116.0.0/17,PROXY
  - IP-CIDR,23.173.192.0/24,PROXY
  - IP-CIDR,103.140.28.0/23,PROXY
  - IP-CIDR,141.193.3.0/24,PROXY
  - IP-CIDR,205.201.62.0/24,PROXY
  - IP-CIDR,209.206.40.0/21,PROXY
  - GEOSITE,roblox,PROXY
  - GEOSITE,rutracker,PROXY
  - GEOSITE,rutracker,PROXY
# direct
  - GEOSITE,category-forums,DIRECT
  - GEOSITE,category-forums,DIRECT
  - GEOSITE,category-games,DIRECT
  - GEOSITE,category-dev,DIRECT
  - GEOSITE,category-ru,DIRECT
  - GEOSITE,category-ads-all,REJECT
# final
  - MATCH,PROXY
      '';
      path = "/etc/mihomo/config.yaml";
      mode = "0600";
    };
    secrets.multi = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.ssh/multi.key";
    };
    templates."git-credentials" = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };
  };
}
