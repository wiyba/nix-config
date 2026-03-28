{
  pkgs,
  inputs,
  host,
  lib,
  ...
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

  networking.firewall.enable = lib.mkDefault false;

  networking.extraHosts = ''
    0.0.0.0 paradise-s1.battleye.com
    0.0.0.0 test-s1.battleye.com
    0.0.0.0 paradiseenhanced-s1.battleye.com
    0.0.0.0 cisco.com www.cisco.com
  '';

  imports = [
    # secrets imported from flake.nix
    ./services/greetd
    ./services/pipewire
    ./services/ssh
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    steam = {
      enable = true;
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
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    niri.enable = true;
  };

  services = {
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
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
    ];
    variables = {
      NIXOS_OZONE_WL = "1";
      SOPS_AGE_KEY_FILE = "/etc/nixos/secrets/sops-age.key";
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
    extraSpecialArgs = { inherit inputs host; };
    users.wiyba = import ../home/wm/niri;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
