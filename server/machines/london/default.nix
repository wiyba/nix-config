{ pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

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
    defaultGateway = "45.154.197.1";
    defaultGateway6 = "2a12:ab46:5344::1";
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "45.154.197.120";
          prefixLength = 24;
        }
      ];
      ipv4.routes = [
        {
          address = "45.154.197.1";
          prefixLength = 32;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a12:ab46:5344:96::a";
          prefixLength = 64;
        }
      ];
      ipv6.routes = [
        {
          address = "2a12:ab46:5344::1";
          prefixLength = 128;
        }
      ];
    };
    usePredictableInterfaceNames = lib.mkForce true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
  };

  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "23.11";
}
