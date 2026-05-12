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
  };

  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
    "77.88.8.8"
  ];
  networking.networkmanager.dns = "none";

  networking.extraHosts = ''
    0.0.0.0 paradise-s1.battleye.com
    0.0.0.0 test-s1.battleye.com
    0.0.0.0 paradiseenhanced-s1.battleye.com
    0.0.0.0 cisco.com www.cisco.com
  '';

  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    ./services/greetd
    ./services/pipewire
    ./services/ssh
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "hid_playstation" ];
    consoleLogLevel = 3;
    initrd = {
      systemd.enable = true;
      verbose = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot.enable = lib.mkForce false;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  hardware.xone.enable = true;

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    steam = {
      enable = true;
      package = pkgs.steam.override { extraArgs = "-cef-disable-gpu"; };
      gamescopeSession.enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gamemode.enable = true;
    nh = {
      enable = true;
      flake = "/etc/nixos";
    };
    nix-ld.enable = true;
    nix-index-database.comma.enable = true;
    uwsm.enable = true;
    hyprland = lib.mkIf (wm == "hyprland") {
      enable = true;
      withUWSM = true;
    };
    niri.enable = wm == "niri";
  };

  services = {
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    fwupd.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      curl
      git
      wget
      lm_sensors
      wl-clipboard
      usb-modeswitch
      libsecret
      proxmark3
      nettools
      dnsutils
      xwayland-satellite
      sbctl
      efibootmgr
      wev
      libinput
    ];
    variables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  users.users.wiyba = {
    isNormalUser = true;
    shell = pkgs.zsh;
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
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs host wm; };
    users.wiyba = import (../home/wm + "/${wm}");
  };

  environment.etc."chromium/policies/managed/custom.json".text = builtins.toJSON {
    SavingBrowserHistoryDisabled = true;
    ClearBrowsingDataOnExitList = [ "download_history" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "wiyba" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start mihomo";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop mihomo";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart mihomo";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
    SUBSYSTEM=="usb", MODE="0666"
  '';

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
      trusted-users = [
        "root"
        "wiyba"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
}
