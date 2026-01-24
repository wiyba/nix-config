{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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

  networking.hostName = "desktop";

  system.stateVersion = "24.11";
}
