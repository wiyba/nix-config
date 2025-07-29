{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../wm/hyprland.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HoldoffTimeoutSec=0
      LidSwitchIgnoreInhibited=no
    '';
  };

  networking.hostName = "thinkpad-x1";

  system.stateVersion = "24.11";
}
