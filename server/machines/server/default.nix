{ pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.rp_filter" = 2; # loose mode like Ubuntu
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.default.forwarding" = 1;
    };
  };

  networking = {
    hostName = "server";

    useNetworkd = true;

    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "77.74.199.151";
          prefixLength = 24;
        }
      ];
      # ipv6.addresses = [
      #   {
      #     address = "2a12:ab46:5344:96::a";
      #     prefixLength = 64;
      #   }
      # ];
    };

    defaultGateway = {
      address = "77.74.199.1";
      interface = "ens3";
    };
    # defaultGateway6 = {
    #   address = "2a12:ab46:5344::1";
    #   interface = "ens3";
    # };

    nameservers = [
      "78.110.174.195"
      "78.157.192.227"
    ];

    useDHCP = false;

    # NAT configuration (Ubuntu-like - no MASQUERADE for host network)
    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ ];
      # No extraCommands - Docker with host network doesn't need NAT
    };

    firewall = {
      enable = false; # Keep disabled like before
    };
  };

  systemd.services."systemd-networkd-wait-online".enable = lib.mkForce false;

  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #
  #   virtualHosts = {
  #     "status.wiyba.org" = {
  #       enableACME = true;
  #       forceSSL = false;
  #     };
  #   };
  # };
  #
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "admin@wiyba.org";
  # };

  systemd.services.network-addresses-ens3.requiredBy = [ "network-setup.service" ];

  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
