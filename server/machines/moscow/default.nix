{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/hysteria
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
  };

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "moscow";
    domain = "wiyba.org";

    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = {
      address = "46.8.29.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "2a0c:9300::1";
      interface = "ens3";
    };
    interfaces.ens3 = {
      ipv4 = {
        addresses = [
          {
            address = "46.8.29.162";
            prefixLength = 24;
          }
        ];
      };
      ipv6 = {
        addresses = [
          {
            address = "2a0c:9300:0:2a::1";
            prefixLength = 48;
          }
        ];
        routes = [
          {
            address = "2a0c:9300::1";
            prefixLength = 128;
          }
        ];
      };
    };
    usePredictableInterfaceNames = lib.mkForce true;
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
