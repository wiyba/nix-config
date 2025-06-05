{ config, pkgs, lib, ... }:

let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
  ];

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in
{
  imports = [ ./misc/singbox (import ../secrets) ];

  networking = {
    extraHosts = "";
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

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    micro
    curl
    git
    sing-geoip
    sing-geosite
    wget
    lm_sensors
  ];

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    openssh = {
      enable = true;
      allowSFTP = true;
    };

    sshd.enable = true;

    printing = {
      enable = true;
    };

    libinput.enable = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
  ] ++ customFonts;
  
  programs.zsh.enable = true;

  console = {
    packages = with pkgs; [ terminus_font ];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    keyMap = "us";
  };

  users.users.wiyba = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.zsh;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;

      trusted-users = [ "root" "wiyba" ];

      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;

      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      keep-outputs = true;
      keep-derivations = true;
    };
  };
}

