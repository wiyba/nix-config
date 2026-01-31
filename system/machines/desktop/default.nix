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
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "video=2560x1440@60" ];

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
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    wev
    libinput
  ];

  #systemd.tmpfiles.rules = [
  #  "d /var/cache/tuigreet 0755 greeter greeter -"
  #];

  networking.hostName = "desktop";

  home-manager.users.wiyba.xdg.configFile = {
    "hypr/hyprland-host.conf".text = ''
      monitor=DP-1,2560x1440@144,0x0,1 #,bitdepth,10,cm,hdr,sdrbrightness,1.4"
      monitor=DP-2,2560x1440@75,0x-1440,1

      workspace=1, monitor:DP-1, default:true, on-created-empty:footclient
      workspace=2, monitor:DP-1
      workspace=3, monitor:DP-1
      workspace=4, monitor:DP-1
      workspace=5, monitor:DP-1
      workspace=6, monitor:DP-1
      workspace=7, monitor:DP-1
      workspace=8, monitor:DP-1
      workspace=9, monitor:DP-1
    '';
    "hypr/hypridle-host.conf".text = ''
      listener {
        on-timeout=loginctl lock-session
        timeout=3600
      }
    '';
  };

  services.pipewire.extraConfig.pipewire."10-sample-rate" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
    };
  };
  system.stateVersion = "24.11";
}
