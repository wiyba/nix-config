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
    kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "42:01:0a:a6:00:02";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "helsinki";
    enableIPv6 = true;
    dhcpcd.enable = true;
  };

  time.timeZone = "Europe/Helsinki";
}
