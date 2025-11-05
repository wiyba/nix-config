{ config, pkgs, lib, inputs, ... }:

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
    # proxy = {
    #   default = "http://127.0.0.1:7897/";
    #   allProxy = "http://127.0.0.1:7897/";
    #   noProxy = "localhost,127.0.0.1,internal.domain";
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

  environment.systemPackages = with pkgs; [
    home-manager
    neovim
    vim
    micro
    curl
    git
    wget
    lm_sensors
  ];

  services = {
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    sshd.enable = true;
    libinput.enable = true;
  };

  console = {
    packages = [ pkgs.terminus_font ]; 
    font = "ter-v28n";
    keyMap = "us";
  };

  programs.zsh.enable = true;

  users.users.wiyba = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.zsh;
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

