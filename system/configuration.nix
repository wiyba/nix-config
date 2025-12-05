{ pkgs, lib, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
    };
    modemmanager = {
      enable = true;
    };
    firewall = {
      enable = false;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
    proxy = {
      allProxy = "http://127.0.0.1:7890/";
      noProxy = "localhost,127.0.0.1";
    };
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

  # services.zapret-discord-youtube = {
  #   enable = true;
  #   config = "general(ALT10)";
  # };

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

  imports = lib.concatMap import [
    ./services
    ./sops
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    uwsm.enable = true;
    hyprland = { enable = true; withUWSM = true; };
  };

  services = {
    openssh = { enable = true; allowSFTP = true; };
    sshd.enable = true;
    libinput.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    # desktopManager.plasma6.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      home-manager
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
    ];
    sessionVariables = { NIXOS_OZONE_WL = "1"; };
    variables = { SOPS_AGE_KEY_FILE = "/etc/nixos/keys/sops-age.key"; };
  };

  console = {
    # packages = [ pkgs.terminus_font ]; 
    # font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    keyMap = "us";
  };

  users.users.wiyba = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.zsh;
  };
  
  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock = {};
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
      trusted-users = [ "root" "wiyba" ];
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };
}

