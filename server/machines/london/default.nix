{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/hysteria
    ../../services/xray
    ../../services/satisfactory
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
    hostName = "london";
    domain = "wiyba.org";

    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "REDACTED";
    defaultGateway6 = "REDACTED";
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "REDACTED";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "REDACTED";
          prefixLength = 32;
        }
      ];
      ipv6.addresses = [
        {
          address = "REDACTED";
          prefixLength = 64;
        }
      ];
      ipv6.routes = [
        {
          address = "REDACTED";
          prefixLength = 128;
        }
      ];
    };
    usePredictableInterfaceNames = lib.mkForce true;
  };

  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
