{
  pkgs,
  lib,
  config,
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

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot.enable = lib.mkForce false;

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

  # hysteria server
  sops.templates.hysteria-config = {
    content = ''
tls:
  cert: /var/lib/acme/wiyba.org/fullchain.pem
  key: /var/lib/acme/wiyba.org/key.pem
trafficStats:
  listen: 127.0.0.1:9999
auth:
  type: password
  password: ${config.sops.placeholder.hysteria-auth}
masquerade:
  type: proxy
  proxy:
    url: https://home.wiyba.org/
    rewriteHost: true
    '';
    path = "/etc/hysteria/config.yaml";
    mode = "0444";
  };

  systemd.services.hysteria-server = {
    description = "Hysteria Server";
    after = [ "network.target" "sops-nix.service" "acme-wiyba.org.service" ];
    wants = [ "acme-finished-wiyba.org.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server";
      Environment = "HYSTERIA_LOG_LEVEL=error";
      Restart = "always";
      User = "root";
    };
  };

  home-manager.users.wiyba.xdg.configFile = {
    "hypr/hyprland-host.conf".text = ''
      bind=SUPER, L, exec, hyprctl dispatch dpms toggle

      monitor=DP-1,2560x1440@144,0x0,1
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
        on-timeout=hyprctl dispatch dpms off
        timeout=600
      }
    '';
  };

  system.stateVersion = "24.11";
}
