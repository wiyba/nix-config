{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
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
    hostName = "relay";
    domain = "wiyba.org";

    dhcpcd.enable = false;
    nameservers = [
      "10.130.0.2"
      "1.1.1.1"
    ];
    defaultGateway = {
      address = "10.130.0.1";
      interface = "eth0";
    };
    interfaces.eth0 = {
      ipv4 = {
        addresses = [
          {
            address = "10.130.0.24";
            prefixLength = 24;
          }
        ];
      };
    };
    usePredictableInterfaceNames = lib.mkForce false;
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
