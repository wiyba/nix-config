{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/health
    ../../services/xray
    ../../services/xray-collect
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "stockholm";
    domain = "wiyba.org";

    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "207.2.120.1";
    defaultGateway6 = {
      address = "2a13:7c82:112::1";
      interface = "eth0";
    };
    interfaces.eth0 = {
      ipv4 = {
        addresses = [
          {
            address = "207.2.120.106";
            prefixLength = 24;
          }
        ];
        routes = [
          {
            address = "207.2.120.1";
            prefixLength = 32;
          }
        ];
      };
      ipv6 = {
        addresses = [
          {
            address = "2a13:7c82:112:d::";
            prefixLength = 64;
          }
        ];
        routes = [
          {
            address = "2a13:7c82:112::1";
            prefixLength = 128;
          }
        ];
      };
    };
    usePredictableInterfaceNames = lib.mkForce false;
  };

  services.udev.extraRules = ''
    ATTR{address}=="34:ad:e2:7f:c4:e8", NAME="eth0"
  '';

  time.timeZone = "Europe/Stockholm";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
