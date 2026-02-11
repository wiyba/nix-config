{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "video=2560x1440@60" ];

    initrd = {
      systemd.enable = true;
      verbose = true;
    };

    #kernelParams = [ "video=2880x1800@60" ];

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 3;
      consoleMode = "max";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    wev
    libinput
  ];

  #systemd.tmpfiles.rules = [
  #  "d /var/cache/tuigreet 0755 greeter greeter -"
  #];

  networking = {
    hostName = "home";
    domain = "wiyba.org";

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    interfaces = {
      enp4s0 = {
        ipv4.addresses = [
          {
            address = "95.165.69.96";
            prefixLength = 19;
          }
          {
            address = "192.168.10.2";
            prefixLength = 24;
          }
        ];
      };
      enx00e04c4d7e = {
        ipv4.addresses = [
          {
            address = "192.168.1.1";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "95.165.64.1";
      interface = "enp4s0";
    };

    nat = {
      enable = true;
      externalInterface = "enp4s0";
      internalInterfaces = [ "enx00e04c4d7e" ];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        2222
        443
        80
      ];
      allowedUDPPorts = [ 443 ];
      interfaces."enx00e04c4d7e".allowedTCPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "enx00e04c4d7e";
      dhcp-range = "192.168.1.100,192.168.1.200,24h";
      dhcp-option = [
        "option:router,192.168.1.1"
        "option:dns-server,1.1.1.1,8.8.8.8"
      ];
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
  - name: LONDON
    type: select
    proxies:
      - london-hyst
      - london-vless
  - name: STOCKHOLM
    type: select
    proxies:
      - stockholm-hyst
      - stockholm-vless

rules:
  - IP-CIDR,128.116.0.0/17,LONDON
  - IP-CIDR,23.173.192.0/24,LONDON
  - IP-CIDR,103.140.28.0/23,LONDON
  - IP-CIDR,141.193.3.0/24,LONDON
  - IP-CIDR,205.201.62.0/24,LONDON
  - IP-CIDR,209.206.40.0/21,LONDON
  - GEOSITE,roblox,LONDON
  - GEOSITE,github,LONDON
  - GEOSITE,rutracker,LONDON
  - GEOSITE,youtube,STOCKHOLM
  - GEOSITE,category-forums,DIRECT
  - GEOSITE,category-games,DIRECT
  - GEOSITE,category-dev,DIRECT
  - GEOSITE,category-ru,DIRECT
  - GEOSITE,category-ads-all,REJECT
  - GEOIP,RU,DIRECT
  - GEOIP,PRIVATE,DIRECT
  - DOMAIN-SUFFIX,wiyba.org,DIRECT
  - MATCH,LONDON
    '';
    path = "/etc/mihomo/config.yaml";
    mode = "0600";
  };

  home-manager.users.wiyba.xdg.configFile = {
    "hypr/hyprland-host.conf".text = ''
      monitor=DP-1,2560x1440@144,0x0,1 #,bitdepth,10,cm,hdr,sdrbrightness,1.4"
      monitor=DP-2,2560x1440@75,0x-1440,1

      workspace=1, monitor:DP-1, default:true, on-created-empty:footclient
      workspace=2, monitor:DP-1
      workspace=3, monitor:DP-1
      workspace=4, monitor:DP-1
      workspace=5, monitor:DP-1
      workspace=6, monitor:DP-1
      workspace=7, monitor:DP-1
      workspace=8, monitor:DP-1
      workspace=9, monitor:DP-1
    '';
    "hypr/hypridle-host.conf".text = ''
      listener {
        on-timeout=loginctl lock-session
        timeout=3600
      }
    '';
  };

  services.pipewire.extraConfig.pipewire."10-sample-rate" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
    };
  };

  system.stateVersion = "24.11";
  systemd.services.navidrome.serviceConfig.EnvironmentFile = config.sops.secrets.navidrome-env.path;

  # SERVER OPTIONS
  services = {
    mihomo = {
      enable = true;
      configFile = "/etc/mihomo/config.yaml";
    };
    navidrome = {
      enable = true;
      settings = {
        DataFolder = "/media/navidrome";
        MusicFolder = "/media/music";
        PlaylistsPath = "/media/navidrome/playlists";
        UILoginBackgroundUrl = "https://i.pinimg.com/736x/b0/fc/d9/b0fcd999b0e3d3f3ef4336db0e218838.jpg";
        "LastFM.Enabled" = true;
        "LastFM.Language" = "ru";
      };
    };
    jellyfin = {
      enable = true;

      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
      };

      transcoding = {
        enableHardwareEncoding = true;
        enableToneMapping = true;
        enableSubtitleExtraction = true;

        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          hevc10bit = true;
          vp9 = true;
          av1 = true;
        };

        hardwareEncodingCodecs = {
          hevc = true;
          av1 = true;
        };
      };
    };
    qbittorrent = {
      enable = true;
      serverConfig = {
        BitTorrent = {
          "Session\\DefaultSavePath" = "/media/downloads";
          "Session\\Interface" = "enp4s0";
          "Session\\InterfaceName" = "enp4s0";
        };
      };
    };
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;

    openssh = {
      enable = true;
      ports = [ 2222 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;

      virtualHosts = {
        "media.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:8096";
          locations."/".proxyWebsockets = true;
          extraConfig = "client_max_body_size 20M;";
        };

        "music.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:4533";
        };

        "home.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:8080";
          locations."/".proxyWebsockets = true;
          locations."/".extraConfig = ''
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };

        "arr.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:9696";
          locations."/".proxyWebsockets = true;
        };

        "show.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:8989";
          locations."/".proxyWebsockets = true;
        };

        "movie.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:7878";
          locations."/".proxyWebsockets = true;
        };

        "wave.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };

        "sub.wiyba.org" = {
          forceSSL = true;
          useACMEHost = "wiyba.org";
          locations."/".proxyPass = "http://127.0.0.1:3010";
          locations."/".extraConfig = ''
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
          '';
        };
      };
    };
  };

  users.users.wiyba.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  users.users.jellyfin.extraGroups = [ "video" "render" ];


  sops.templates.hysteria-config = {
    content = ''
      acme:
        domains:
          - ${config.networking.fqdn}
        email: admin@wiyba.org
      trafficStats:
        listen: 127.0.0.1:9999
      auth:
        type: userpass
        userpass: 
          ${config.sops.placeholder.hysteria-auth}
      masquerade:
        type: proxy
        proxy:
          url: https://home.wiyba.org/
          rewriteHost: true
    '';
    path = "/etc/hysteria/config.yaml";
    mode = "0444";
  };
  systemd.services.hysteria-server = {
    description = "Hysteria Server";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server";
      Environment = "HYSTERIA_LOG_LEVEL=error";
      Restart = "always";
      User = "root";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
    certs."wiyba.org" = {
      domain = "*.wiyba.org";
      dnsProvider = "cloudflare";
      environmentFile = "/run/secrets/cloudflare";
    };
  };

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      remnawave-db = {
        image = "postgres:17.6";
        hostname = "remnawave-db";
        ports = [ "127.0.0.1:6767:5432" ];
        volumes = [ "remnawave-db-data:/var/lib/postgresql/data" ];
        environmentFiles = [ /etc/remnawave/.env ];
        environment = {
          POSTGRES_HOST_AUTH_METHOD = "trust";
          TZ = "UTC";
        };
        extraOptions = [ "--network=remnawave-network" ];
      };

      remnawave-redis = {
        image = "valkey/valkey:8.1-alpine";
        hostname = "remnawave-redis";
        volumes = [ "remnawave-redis-data:/data" ];
        extraOptions = [ "--network=remnawave-network" ];
      };

      remnawave = {
        image = "remnawave/backend:2";
        hostname = "remnawave";
        ports = [ "127.0.0.1:3000:3000" ];
        environmentFiles = [ /etc/remnawave/.env ];
        dependsOn = [ "remnawave-db" "remnawave-redis" ];
        extraOptions = [ "--network=remnawave-network" ];
      };

      remnawave-subscription-page = {
        image = "remnawave/subscription-page:latest";
        hostname = "remnawave-subscription-page";
        ports = [ "127.0.0.1:3010:3010" ];
        environmentFiles = [ /etc/remnawave/sub.env ];
        extraOptions = [ "--network=remnawave-network" ];
      };
    };
  };

  systemd.services.docker-remnawave-network = {
    description = "remnawave docker fix";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker network create remnawave-network || true";
      ExecStop = "${pkgs.docker}/bin/docker network rm remnawave-network || true";
    };
  };
}
