{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      systemd.enable = true;
      verbose = true;
    };

    #kernelParams = [ "video=2880x1800@60" ];

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 3;
      consoleMode = "max";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    wev
    libinput
    tpm2-tss
  ];

  #systemd.tmpfiles.rules = [
  #  "d /var/cache/tuigreet 0755 greeter greeter -"
  #];

  networking.hostName = "desktop";

  home-manager.users.wiyba = {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        "DP-1,2560x1440@144,0x1440,1" # ,bitdepth,10,cm,hdr,sdrbrightness,1.4"
        "DP-2,2560x1440@75,0x0,1"
      ];

      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:DP-2, default:true"
        "7, monitor:DP-2"
        "8, monitor:DP-2"
        "9, monitor:DP-2"
        "10, monitor:DP-2"
      ];
    };

    services.hyprpaper.settings = {
      wallpaper = lib.mkForce [
        {
          monitor = "DP-1";
          path = "/etc/nixos/imgs/gruvbox-dark-blue.png";
          fit_mode = "cover";
        }
        {
          monitor = "DP-2";
          path = "/etc/nixos/imgs/gruvbox-dark-blue.png";
          fit_mode = "cover";
        }
        {
          monitor = "";
          path = "/etc/nixos/imgs/gruvbox-dark-blue.png";
          fit_mode = "cover";
        }
      ];
    };

    services.hypridle.settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  system.stateVersion = "24.11";
}
