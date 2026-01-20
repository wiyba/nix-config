#template
{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  networking = {
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = false;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
  };

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

  #time.timeZone = "Europe/Moscow";

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    uwsm.enable = true;
    steam.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    sshd.enable = true;
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    # desktopManager.plasma6.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      vim
      micro
      curl
      git
      wget
      lm_sensors
      kitty
      wl-clipboard
      usb-modeswitch
      uxplay
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    variables = {
      SOPS_AGE_KEY_FILE = "/etc/nixos/keys/sops-age.key";
    };
  };

  console = {
    # packages = [ pkgs.terminus_font ];
    # font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    keyMap = "us";
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
    ];
    shell = pkgs.zsh;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
      inputs.lazyvim.homeManagerModules.default
      inputs.spicetify-nix.homeManagerModules.spicetify
    ];
    users.wiyba = import ../home/home.nix;
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock = { };
  };

  # make nixos config accessible by anyone
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
    };
  };
  nixpkgs.config.allowUnfree = true;
}
