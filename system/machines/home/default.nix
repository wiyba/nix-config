{ pkgs
, config
, inputs
, lib
, ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ../../services/nginx
    ../../services/mihomo
    ../../services/xcli
    ../../services/printing
    ../../services/qbittorrent
  ];

  boot = {
    kernelParams = [ "video=2560x1440@60" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
  };

  powerManagement.cpuFreqGovernor = "performance";

  systemd.network.links = {
    "10-wan0" = {
      matchConfig.MACAddress = "2c:f0:5d:04:be:05";
      linkConfig.Name = "wan0";
    };
    "10-lan0" = {
      matchConfig.MACAddress = "00:e0:4c:4d:7e:20";
      linkConfig.Name = "lan0";
    };
  };

  systemd.services.NetworkManager-wait-online.serviceConfig = {
    ExecStart = [
      ""
      "${pkgs.networkmanager}/bin/nm-online -q --timeout=2"
    ];
  };

  systemd.services.offloads-fix = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.ethtool}/bin/ethtool -K wan0 tso off gso off gro off || true
      ${pkgs.ethtool}/bin/ethtool -s wan0 wol g || true
    '';
  };

  networking = {
    hostName = "home";
    domain = "wiyba.org";
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
            address1 = "192.168.10.2/24";
            method = "auto";
            ignore-auto-dns = true;
            dns = "1.1.1.1;8.8.8.8;77.88.8.8;";
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

    firewall = {
      enable = true;
      trustedInterfaces = [ "lan0" "Meta" ];
      checkReversePath = "loose";
      allowedTCPPorts = [
        80
        443
        2222
        27036
        27037
      ];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ];
    };
  };


  home-manager.users.wiyba.xdg.configFile = {
    "niri/outputs.kdl".text = ''
      output "DP-1" {
          mode "2560x1440@143.999"
          scale 1.0
          transform "normal"
          position x=0 y=0
      }

      output "DP-2" {
          mode "2560x1440@75"
          scale 1.0
          transform "normal"
          position x=0 y=-1440
      }

      workspace "social" {
          open-on-output "DP-2"
      }
      workspace "media" {
          open-on-output "DP-2"
      }
    '';
    "hypr/hyprland-host.conf".text = ''
      exec= pkill hyprpaper; hyprpaper
      bind=SUPER, L, exec, hyprctl dispatch dpms toggle

      monitor=DP-1,2560x1440@144,0x0,1
      monitor=DP-2,2560x1440@75,0x-1440,1

      workspace=1, monitor:DP-1, default:true
      workspace=2, monitor:DP-1
      workspace=3, monitor:DP-1
      workspace=4, monitor:DP-1
      workspace=5, monitor:DP-1
      workspace=6, monitor:DP-1
      workspace=7, monitor:DP-1
      workspace=8, monitor:DP-1
      workspace=9, monitor:DP-1
    '';
    "hypr/hyprpaper.conf".text = ''
      preload=/etc/nixos/imgs/nix4.png
      wallpaper {
          monitor=DP-1
          fit_mode=cover
          path=/etc/nixos/imgs/nix4-oled.png
      }
      wallpaper {
          monitor=DP-2
          path=
      }
      splash=false
    '';
  };

  #media
  users.groups.media = { };
  services.jellyfin = {
    enable = true;
    group = "media";
    dataDir = "/media/jellyfin";
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
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
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];
  services.navidrome = {
    enable = true;
    group = "media";
    settings = {
      DataFolder = "/media/navidrome";
      MusicFolder = "/media/music";
      PlaylistsPath = "/media/navidrome/playlists";
      UILoginBackgroundUrl = "https://i.pinimg.com/736x/b0/fc/d9/b0fcd999b0e3d3f3ef4336db0e218838.jpg";
      "LastFM.Enabled" = true;
      "LastFM.Language" = "ru";
    };
  };
  systemd.services.navidrome.serviceConfig.EnvironmentFile = config.sops.secrets.navidrome-env.path;
  sops.secrets.navidrome-env = {
    owner = "navidrome";
  };

  programs.steam.gamescopeSession.args = [
    "-W"
    "2560"
    "-H"
    "1440"
    "-r"
    "144"
  ];

  specialisation.clean.configuration = {
    systemd.services.jellyfin.wantedBy = lib.mkForce [ ];
    systemd.services.navidrome.wantedBy = lib.mkForce [ ];
    systemd.services.qbittorrent.wantedBy = lib.mkForce [ ];
    systemd.services.nginx.wantedBy = lib.mkForce [ ];
    systemd.services.wba-website.wantedBy = lib.mkForce [ ];
    systemd.services.mihomo.wantedBy = lib.mkForce [ ];
    systemd.services.xcli.wantedBy = lib.mkForce [ ];
    systemd.services.cups.wantedBy = lib.mkForce [ ];
    systemd.sockets.cups.wantedBy = lib.mkForce [ ];
    systemd.services.avahi-daemon.wantedBy = lib.mkForce [ ];
    systemd.sockets.avahi-daemon.wantedBy = lib.mkForce [ ];
  };
}
