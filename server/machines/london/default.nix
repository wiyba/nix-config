{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/acme
    ../../services/xray
    #../../services/satisfactory
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "00:46:d9:64:86:d3";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "london";
    enableIPv6 = true;
    defaultGateway = "45.154.197.1";
    defaultGateway6 = "2a12:ab46:5344::1";
    interfaces.wan0 = {
      ipv4.addresses = [
        { address = "45.154.197.120"; prefixLength = 24; }
      ];
      ipv6.addresses = [
        { address = "2a12:ab46:5344:96::a"; prefixLength = 64; }
      ];
      ipv6.routes = [
        { address = "2a12:ab46:5344::1"; prefixLength = 128; }
      ];
    };
  };

  time.timeZone = "Europe/London";
}
