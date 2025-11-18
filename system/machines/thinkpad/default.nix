{ pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixos-boot = {
    enable = true;
    duration = 5;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      systemd.enable = true;
      verbose = false;
      luks.devices = {
      cryptroot = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };

    # configured in nixos-boot={};
    # plymouth = {
    #   enable = true;
    #   theme = "lone";
    #   themePackages = [ pkgs.adi1090x-plymouth-themes ];
    # };

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=2880x1800"
    ];
    
    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 3;
      consoleMode = "max";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  systemd.services = {
    ModemManager = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart     = "always";
        RestartSec  = "2s";
      };
    };
    modem-fix = {
      description = "Fix Lenovo Connect modem initialization";
      wantedBy = [ "post-resume.target" ];
      after = [ "post-resume.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "modem-fix" ''
          sleep 1
          ${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 2dee -p 4d54 -R || true
          sleep 1
          ${pkgs.systemd}/bin/systemctl restart ModemManager.service
          sleep 1
          ${pkgs.modemmanager}/bin/mmcli -S
          echo "done"
          echo "done"
          echo "done"
          echo "done"
          exit 0
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    brightnessctl
    wev
    libinput
    tpm2-tss
  ];

  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };
  };

  systemd.tmpfiles.rules = [
    "z /sys/class/leds/*/brightness 0666 - - - -"
    "z /sys/class/leds/*/trigger 0666 - - - -"
    "d /var/cache/tuigreet 0755 greeter greeter -"
  ];

  security = {
     tmp2 = {
      enable = true;
      tctiEnvironment.enable = true;
    }; 

    fprintd.enable = true;
    pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth  = true;
      polkit-1.fprintAuth = true;
      hyprlock.fprintAuth = true;
    };
  };

  networking.hostName = "thinkpad";

  system.stateVersion = "24.11";
}
