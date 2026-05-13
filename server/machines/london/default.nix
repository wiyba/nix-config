{ pkgs, lib, config, ... }:
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

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "london";
    domain = "wiyba.org";
    useNetworkd = true;
    useDHCP = false;
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
  };

  sops.templates."london-network" = {
    path = "/etc/systemd/network/05-wan.network";
    owner = "root";
    mode = "0644";
    content = ''
      [Match]
      MACAddress=00:46:d9:64:86:d3

      [Network]
      Address=${config.sops.placeholder.xray-london-ip}/24
      Address=${config.sops.placeholder.xray-london-ipv6}/64
      Gateway=${config.sops.placeholder.xray-london-gw}
      Gateway=${config.sops.placeholder.xray-london-gw6}
      DNS=1.1.1.1
      DNS=8.8.8.8
      DNS=77.88.8.8
    '';
    restartUnits = [ "systemd-networkd.service" ];
  };

  time.timeZone = "Europe/London";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
