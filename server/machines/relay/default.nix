{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/mihomo
    ../../services/acme
    ../../services/xray
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      timeoutStyle = "countdown";
      extraConfig = ''
        serial --unit=0 --speed=115200
        terminal_input serial console
        terminal_output serial console
      '';
    };
    kernelParams = [ "console=tty1" "console=ttyS0,115200n8" "ipv6.disable=1" ];
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "d0:0d:7a:f2:84:92";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "relay";
    dhcpcd = {
      enable = true;
      extraConfig = "nooption domain_name_servers";
    };
    nameservers = [
      "77.88.8.8"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  time.timeZone = "Europe/Moscow";
}
