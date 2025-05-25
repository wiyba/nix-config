{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../wm/hyprland.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      grub-boot.enable = true;
      device = "nodev";
      useOSProber = false;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking.hostName = "nixos-usb";

  system.stateVersion = "24.11";
}