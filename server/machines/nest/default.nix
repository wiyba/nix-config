{ config
, pkgs
, lib
, inputs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  nix.registry.nixpkgs.flake = lib.mkForce null;
  boot.loader.raspberry-pi.bootloader = "kernel";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  systemd.network.links = {
    "10-wan0" = {
      matchConfig.MACAddress = "2c:cf:67:82:6e:3f";
      linkConfig.Name = "wan0";
    };
    "10-lan0" = {
      matchConfig.MACAddress = "00:e0:4c:45:66:80";
      linkConfig.Name = "lan0";
    };
  };

  networking = {
    hostName = "nest";
    useDHCP = false;

    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        wan0 = {
          connection = {
            id = "wan0";
            type = "ethernet";
            interface-name = "wan0";
          };
          ipv4 = {
            method = "manual";
            address1 = "185.13.46.77/25";
            gateway = "185.13.46.1";
            dns = "1.1.1.1;8.8.8.8;";
            ignore-auto-dns = "true";
          };
        };

        lan0 = {
          connection = {
            id = "lan0";
            type = "ethernet";
            interface-name = "lan0";
          };
          ipv4 = {
            address1 = "192.168.1.1/24";
            method = "shared";
          };
        };
      };
    };

    nat = {
      enable = true;
      externalInterface = "wan0";
      internalInterfaces = [ "lan0" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "lan0" ];
      allowedTCPPorts = [ 2222 ];
    };
  };

  environment.systemPackages = with pkgs; [
    proxmark3
  ];

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
