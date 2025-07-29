{ config, pkgs, lib, ... }:

let
  nerdFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
  ];
in
{
  networking = {
    extraHosts = "";
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
    micro curl
    git
    wget
    lm_sensors
    clash-verge-rev # best vless client for now
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
  ] ++ nerdFonts;
  
  programs.zsh.enable = true;

  security = {
    sudo = {
      # needed to run clash-verge's tun mode without issues
      extraRules = [ { users = [ "wiyba" ]; commands = [{ command = "/nix/store/*/bin/clash-verge-service"; options = [ "NOPASSWD" "SETENV" ]; }]; }];
    };
  };

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

