{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../wm/hyprland.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.grub = {
     	enable = true;
     	device = "nodev";
     	efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking.hostName = "nix-usb";

  system.stateVersion = "24.11";
}
