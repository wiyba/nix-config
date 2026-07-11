{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/acme
    ../../services/mailserver
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      timeout = 0;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        timeoutStyle = "countdown";
        extraConfig = ''
          serial --unit=0 --speed=115200
          terminal_input serial console
          terminal_output serial console
        '';
      };
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "42:01:0a:a6:00:03";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "helsinki";
    enableIPv6 = true;
    dhcpcd = {
      enable = true;
      extraConfig = "nooption domain_name_servers";
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "77.88.8.8"
    ];
  };

  time.timeZone = "Europe/Helsinki";
}
