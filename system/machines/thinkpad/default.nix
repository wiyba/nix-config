{ pkgs, lib, inputs, config, ... }:

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

    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 5;
      consoleMode = "max";
      
      extraEntries = {
        "windows.conf" = ''
          title Windows
          efi /EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    brightnessctl
    wev
    libinput
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "ignore";
  };

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth  = true;
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = true;

  networking.hostName = "thinkpad";

  system.stateVersion = "24.11";
}
