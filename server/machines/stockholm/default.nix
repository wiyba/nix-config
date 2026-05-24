{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/acme
    ../../services/xray
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "34:ad:e2:7f:c4:e8";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "stockholm";
    enableIPv6 = true;
    defaultGateway = "193.53.40.1";
    defaultGateway6 = "2a13:7c81::1";
    interfaces.wan0 = {
      ipv4.addresses = [
        { address = "193.53.40.182"; prefixLength = 24; }
      ];
      ipv6.addresses = [
        { address = "2a13:7c81:fff::1bc"; prefixLength = 128; }
      ];
      ipv6.routes = [
        { address = "2a13:7c81::1"; prefixLength = 128; }
      ];
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "77.88.8.8"
    ];
  };

  time.timeZone = "Europe/Stockholm";
}
