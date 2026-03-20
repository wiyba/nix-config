{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ../../services/nginx
    ../../services/mihomo
    ../../services/xcli
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "video=2560x1440@60" ];

    initrd = {
      systemd.enable = true;
      verbose = true;
    };

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
  };

  networking = {
    hostName = "home";
    domain = "wiyba.org";
    useDHCP = false;

    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        enp0s20f0u1 = {
          connection = {
            id = "enp0s20f0u1";
            type = "ethernet";
            interface-name = "enp0s20f0u1";
          };
          ipv4 = {
            address1 = "192.168.1.1/24";
            method = "shared";
          };
        };

        enp4s0 = {
          connection = {
            id = "enp4s0";
            type = "ethernet";
            interface-name = "enp4s0";
          };
          ipv4 = {
            address1 = "192.168.10.2/24";
            dns = "1.1.1.1;8.8.8.8;";
            ignore-auto-dns = "true";
            method = "auto";
          };
        };
      };
    };

    nat = {
      enable = true;
      externalInterface = "enp4s0";
      internalInterfaces = [ "enp0s20f0u1" ];
    };

    firewall = {
      enable = false;
      allowedTCPPorts = [
        80
        443
        2222
      ];
      allowedUDPPorts = [ 443 ];
      trustedInterfaces = [ "enp0s20f0u1" ];
    };
  };

  # printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    wev
    libinput
  ];

  # xray vless+reality inbound
  sops.templates.xray-config = {
    content = builtins.toJSON {
      log = { loglevel = "warning"; };
      inbounds = [
        {
          listen = "0.0.0.0";
          port = 8443;
          protocol = "vless";
          settings = {
            clients = [
              { id = "${config.sops.placeholder.vless-uuid}"; flow = "xtls-rprx-vision"; }
            ];
            decryption = "none";
          };
          streamSettings = {
            network = "tcp";
            security = "reality";
            realitySettings = {
              dest = "vk.com:443";
              serverNames = [ "vk.com" ];
              privateKey = "${config.sops.placeholder.xcli-private-key}";
              shortIds = [ "AAAA5555" ];
            };
          };
        }
      ];
      outbounds = [
        { protocol = "freedom"; }
      ];
    };
    path = "/etc/xray/config.json";
    mode = "0600";
  };
  systemd.services.xray = {
    description = "xray";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xray}/bin/xray run -c /etc/xray/config.json";
      Restart = "always";
    };
  };

  home-manager.users.wiyba.xdg.configFile = {
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

  #gaems
  services.terraria = {
    enable = true;
    openFirewall = true;
    messageOfTheDay = "добро пожлаовать в комююююютер веби!";
    worldPath = "/var/lib/terraria/sin-vzriva-pirojka.wld";
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
    "-W" "2560"
    "-H" "1440"
    "-r" "144"
  ];

  system.stateVersion = "24.11";
}
