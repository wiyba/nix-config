{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/health
    ../../services/xray
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
      address = "REDACTED";
      interface = "ens3";
    };
    interfaces.ens3 = {
      ipv4 = {
        addresses = [
          {
            address = "REDACTED";
            prefixLength = 24;
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
