{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  nix.registry.nixpkgs.flake = lib.mkForce null;
  boot.loader.raspberry-pi.bootloader = "kernel";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  systemd.network.links = {
    "10-wan0" = {
      matchConfig.MACAddress = "2c:cf:67:82:6e:3f";
      linkConfig.Name = "wan0";
    };
    "10-lan0" = {
      matchConfig.MACAddress = "00:e0:4c:45:66:80";
      linkConfig.Name = "lan0";
    };
  };

  networking = {
    hostName = "rpi5";
    useDHCP = false;

    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        wan0 = {
          connection = {
            id = "wan0";
            type = "ethernet";
            interface-name = "wan0";
          };
          ipv4 = {
            method = "manual";
            address1 = "185.13.46.77/25";
            gateway = "185.13.46.1";
            dns = "1.1.1.1;8.8.8.8;";
            ignore-auto-dns = "true";
          };
        };

        lan0 = {
          connection = {
            id = "lan0";
            type = "ethernet";
            interface-name = "lan0";
          };
          ipv4 = {
            address1 = "192.168.1.1/24";
            method = "shared";
          };
        };
      };
    };

    nat = {
      enable = true;
      externalInterface = "wan0";
      internalInterfaces = [ "lan0" ];
    };
  };

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
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      StateDirectory = "mihomo";
      Restart = "on-failure";
      RestartSec = "5s";
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
          server: REDACTED
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

      rules:
        - GEOIP,PRIVATE,DIRECT
        - DOMAIN-SUFFIX,wiyba.org,DIRECT
        - GEOSITE,category-ru,DIRECT
        - MATCH,relay
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };

  environment.systemPackages = with pkgs; [
    proxmark3
  ];

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
