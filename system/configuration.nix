{
  pkgs,
  inputs,
  host,
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

  imports = [
    ./secrets
    ./modules/networking
    ./programs/git
    ./programs/ssh
    ./programs/zsh
    ./services/greetd
    ./services/pipewire
    ./services/ssh
    ./services/systemd
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    uwsm.enable = true;
    steam.enable = true;
    gamescope.enable = true;
    nix-ld.enable = true;
    nix-index-database.comma.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
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
    ];
    variables = {
      NIXOS_OZONE_WL = "1";
      SOPS_AGE_KEY_FILE = "/etc/nixos/system/secrets/sops-age.key";
    };
  };

  users.users.wiyba = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "dialout"
      "media"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs host; };
    users.wiyba = import ../home/wm/hyprland;
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
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
}
