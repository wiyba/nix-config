{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../services/mihomo
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      systemd.enable = true;
      verbose = true;
      luks.devices.cryptroot = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };

    kernelParams = [ "video=2880x1800@60" ];

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

  hardware.bluetooth.enable = true;

  systemd.services = {
    ModemManager = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
      };
    };
    fprint-fix = {
      description = "Reset fingerprint sensor after resume";
      wantedBy = [ "post-resume.target" ];
      after = [ "post-resume.target" ];
      before = [ "fprintd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fprint-fix" ''
          ${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 06cb -p 0123 -R || true
          sleep 1
          ${pkgs.systemd}/bin/systemctl restart --no-block fprintd.service || true
        '';
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
  ];

  security = {
    tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
    };

    pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
      hyprlock.fprintAuth = true;
    };
  };

  services.fprintd.enable = true;

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  home-manager.users.wiyba.xdg.configFile = {
    "hypr/hyprland-host.conf".text = ''
      bind=SUPER, L, exec, hyprlock

      exec-once=pactl-listener

      monitor=eDP-1,2880x1800@60,0x0,1.5
      monitor=,preferred,auto,1

      workspace=1, monitor:eDP-1, default:true
      workspace=2, monitor:eDP-1
      workspace=3, monitor:eDP-1
      workspace=4, monitor:eDP-1
      workspace=5, monitor:eDP-1
      workspace=6, monitor:eDP-1
      workspace=7, monitor:eDP-1
      workspace=8, monitor:eDP-1
      workspace=9, monitor:eDP-1

      decoration:blur:enabled = false
      decoration:shadow:enabled = false
      decoration:inactive_opacity = 1.0

      misc:key_press_enables_dpms = true
      misc:mouse_move_enables_dpms = true
    '';
    "hypr/hypridle-host.conf".text = ''
      listener {
        on-resume=brightnessctl -r
        on-timeout=brightnessctl -s && brightnessctl set 11%- && brightnessctl set +1%
        timeout=540
      }
      listener {
        on-resume=hyprctl dispatch dpms on
        on-timeout=hyprctl dispatch dpms off
        timeout=600
      }
    '';
  };

  system.stateVersion = "24.11";
}
