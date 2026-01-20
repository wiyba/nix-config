{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.efi = {
      canTouchEfiVariables = false;
    };

    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;
      efiInstallAsRemovable = true;
    };
  };

  networking.hostName = "ms-7c39";

  system.stateVersion = "24.11";
}
