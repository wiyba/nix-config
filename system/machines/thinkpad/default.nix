{ pkgs, inputs, config, ... }:

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
      gfxmodeEfi = "2880x1800";
      useOSProber = true;
      theme = inputs.grub-themes.packages.${pkgs.system}.hyperfluent;
      # custom installation scripts for tpm and secure boot support
      extraInstallCommands = ''
        ESP="${config.boot.loader.efi.efiSysMountPoint or "/boot"}"
        export PATH=${pkgs.efibootmgr}/bin:$PATH
        ${pkgs.grub2_efi}/bin/grub-install \
          --target=x86_64-efi \
          --efi-directory="$ESP" \
          --bootloader-id=NixOS-boot \
          --modules="tpm" \
          --disable-shim-lock
        '';
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

  # fprint scaner support
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth  = true;
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = true;
  
  # sign all files for secure boot support
  system.activationScripts.signEfiWithSbctl = {
    supportsDryActivation = true;
    text = ''
      SBCTL=${pkgs.sbctl}/bin/sbctl
      ESP="${config.boot.loader.efi.efiSysMountPoint or "/boot"}"
  
      sign_file() {
        f="$1"
        [ -e "$f" ] || return 0
        echo "Signing $f with sbctl…"
        "$SBCTL" sign -s "$f" || true
      }

      if [ -d "$ESP/EFI" ]; then
        for f in $(find "$ESP/EFI" -type f -name '*.efi'); do
          sign_file "$f"
        done
      fi

      if [ -d /boot/grub ]; then
        for f in $(find /boot/grub -type f -name '*.efi'); do
          sign_file "$f"
        done
      fi

      if [ -d /boot/kernels ]; then
        for f in /boot/kernels/*-linux-*-bzImage; do
          [ -e "$f" ] && sign_file "$f"
        done
      fi
    '';
  }; 

  networking.hostName = "thinkpad";

  system.stateVersion = "24.11";
}
