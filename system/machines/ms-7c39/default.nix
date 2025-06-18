{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../wm/hyprland.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    
    loader.efi = {
	canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
    };    

    loader.grub = {
     	enable = true;
     	device = "nodev";
     	efiSupport = true;
	useOSProber = true;
	efiInstallAsRemovable = false;
    };
  };

  networking.hostName = "ms-7c39";

  system.stateVersion = "24.11";
}
