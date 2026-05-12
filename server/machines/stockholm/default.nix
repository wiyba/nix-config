{ pkgs, lib, ... }:
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

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "stockholm";
    domain = "wiyba.org";
    usePredictableInterfaceNames = lib.mkForce false;
  };

  time.timeZone = "Europe/Stockholm";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
