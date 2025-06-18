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
      extraConfig = ''
        set gfxmode=2560x1440
        set gfxpayload=keep
      '';
    };
  };

  networking.hostName = "nix-usb";

  system.stateVersion = "24.11";
}
