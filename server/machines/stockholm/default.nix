{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
  };

  services.logrotate.checkConfig = false;
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
    defaultGateway = "10.0.0.1";
    interfaces.ens3 = {
      ipv4 = {
        addresses = [
          {
            address = "87.121.105.20";
            prefixLength = 32;
          }
        ];
        routes = [
          {
            address = "10.0.0.1";
            prefixLength = 32;
          }
        ];
      };
    };
    usePredictableInterfaceNames = lib.mkForce true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "stockholm.wiyba.org" = {
        enableACME = true;
        forceSSL = false;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@wiyba.org";
  };

  time.timeZone = "Europe/Stockholm";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
