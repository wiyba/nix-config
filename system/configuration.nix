{ pkgs
, inputs
, host
, wm
, lib
, ...
}:

{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
    };
  };

  time.timeZone = "Europe/Moscow";

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    "net.core.somaxconn" = 4096;
    "vm.swappiness" = 10;
  };

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "77.88.8.8"
    ];
    enableIPv6 = lib.mkDefault false;
    networkmanager.dns = "none";
    extraHosts = ''
      0.0.0.0 paradise-s1.battleye.com
      0.0.0.0 test-s1.battleye.com
      0.0.0.0 paradiseenhanced-s1.battleye.com
      0.0.0.0 cisco.com www.cisco.com
    '';
  };

  imports = [
    ./services/greetd
    ./services/pipewire
    ./services/ssh
    ./services/flatpak
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "hid_playstation" ];
    kernelParams = [
      "ipv6.disable=1"
      "udev.log_level=3"
      "8250.nr_uarts=0"
    ];
    initrd = {
      systemd.enable = true;
      verbose = false;
    };
    loader = {
      timeout = 1;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot.enable = true;
    };
  };

  hardware = {
    xone.enable = true;
    bluetooth.enable = true;
  };

  programs = {
    uwsm.enable = wm == "hyprland";
    hyprland.enable = wm == "hyprland";
    hyprland.withUWSM = wm == "hyprland";
    niri.enable = wm == "niri";

    zsh.enable = true;
    dconf.enable = true;
    gamemode.enable = true;
    nix-ld.enable = true;
    nix-index-database.comma.enable = true;

    nh = {
      enable = true;
      flake = "/etc/nixos";
    };

    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraArgs = "-cef-disable-gpu -nobootstrapupdate -skipinitialbootstrap";
      };
      gamescopeSession.enable = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  services = {
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    udev.packages = [ pkgs.proxmark3 pkgs.chrommium ];
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      curl
      git
      wget
      lm_sensors
      brightnessctl
      wl-clipboard
      usb-modeswitch
      libsecret
      proxmark3
      nettools
      dnsutils
      wakeonlan
      xwayland-satellite
      sbctl
      efibootmgr
      wev
      libinput
      android-tools
      file
      psmisc
      lsof
      usbutils
      pciutils
      dmidecode
      smartmontools
      ethtool
      parted
      mtr
      tcpdump
      ntfs3g
      xxd
      tpm2-tss
      tmux
      p7zip
      libarchive
    ];
    variables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  users.users.wiyba = {
    isNormalUser = true;
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$1ZGpYEWAc11NmYLtyggch.$BPfQ3XJh0qRANS9khQBTifk21PaQbEHxfwNt.xDuIn8";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "dialout"
      "media"
      "hysteria"
      "seat"
      "adbusers"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs host wm; };
    users.wiyba = import (../home/wm + "/${wm}");
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
  };

  systemd.tmpfiles.rules = [
    "d /etc/nixos 0755 wiyba users - -"
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      accept-flake-config = true;
      trusted-users = [
        "root"
        "wiyba"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      fallback = true;
      connect-timeout = 5;
      stalled-download-timeout = 30;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.thalheim.io"
        "https://noctalia.cachix.org"
        "https://zed.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
