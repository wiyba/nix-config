{
  pkgs,
  inputs,
  host,
  ...
}:

{
  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      connectionConfig."ipv4.ignore-auto-dns" = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    # proxy = {
    #   allProxy = "http://127.0.0.1:7890/";
    #   httpProxy = "http://127.0.0.1:7890/";
    #   httpsProxy = "http://127.0.0.1:7890/";
    #   noProxy = "localhost,127.0.0.1";
    # };
    extraHosts = ''
      142.54.189.109 gew1-spclient.spotify.com
      142.54.189.109 login5.spotify.com
      142.54.189.109 spotify.com
      142.54.189.109 api.spotify.com
      142.54.189.109 appresolve.spotify.com
      142.54.189.109 accounts.spotify.com
      142.54.189.109 aet.spotify.com
      142.54.189.109 open.spotify.com
      142.54.189.109 spotifycdn.com
      142.54.189.109 www.spotify.com
    '';
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
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

  time.timeZone = "Europe/Moscow";

  imports = [
    ./secrets
    ./services/greetd
    ./services/mihomo
    ./services/pipewire
    ./services/systemd
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    uwsm.enable = true;
    steam.enable = true;
    nix-ld.enable = true;
    nix-index-database.comma.enable = true;
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
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
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
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    variables = {
      SOPS_AGE_KEY_FILE = "/etc/nixos/keys/sops-age.key";
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
    ];
    shell = pkgs.zsh;
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
    };
  };
  nixpkgs.config.allowUnfree = true;
}
