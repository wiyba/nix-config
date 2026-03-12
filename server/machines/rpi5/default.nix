{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking = {
    hostName = "rpi5";
    useDHCP = true;
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  sops.secrets = lib.mkForce { };
  sops.templates = lib.mkForce { };

  system.stateVersion = "24.11";
}
