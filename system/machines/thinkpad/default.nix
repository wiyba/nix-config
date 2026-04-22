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
    kernelModules = [ "hid_playstation" ];
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = true;
      luks.devices.cryptroot = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
        bypassWorkqueues = true;
      };
      systemd.services.early-backlight = {
        wantedBy = [ "cryptsetup.target" ];
        before = [ "systemd-cryptsetup@cryptroot.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = ''
          while [ ! -e /sys/class/backlight/intel_backlight/brightness ]; do sleep 0.1; done
          echo 40 > /sys/class/backlight/intel_backlight/brightness
        '';
      };
    };

    kernelParams = [
      "video=eDP-1:2880x1800@60"
      "i915.enable_dpcd_backlight=1"
    ];

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 10;
      consoleMode = "max";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  networking = {
    hostName = "thinkpad";
    useDHCP = false;
    networkmanager = {
      enable = true;
      ensureProfiles.profiles.cdc-wdm0 = {
        connection = {
          id = "cdc-wdm0";
          type = "gsm";
          autoconnect = true;
        };
        gsm = {
          auto-config = true;
        };
        ipv4.method = "auto";
        ipv6 = {
          method = "auto";
          never-default = true;
        };
      };
    };
    modemmanager.enable = true;
    usePredictableInterfaceNames = lib.mkForce true;
  };

  hardware.bluetooth.enable = true;

  systemd.services = {
    ModemManager = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
        TimeoutStopSec = "5s";
        KillMode = "mixed";
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

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", \
      RUN+="${pkgs.util-linux}/bin/runuser -u wiyba -- ${pkgs.bash}/bin/bash -lc 'WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 niri-refresh-switch || true'"
  '';

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
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "hibernate";
    };
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "3h";

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # systemd.services.upower.serviceConfig = {
  #   ProtectSystem = lib.mkForce "no";
  #   PrivateTmp = lib.mkForce false;
  # };

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

  services.fwupd.enable = true;

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

      PLATFORM_PROFILE_ON_BAT = "low-power";

      PCIE_ASPM_ON_BAT = "powersupersave";

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  home-manager.users.wiyba.xdg.configFile = {
    "niri/outputs.kdl".text = ''
      output "eDP-1" {
          mode "2880x1800@60"
          scale 1.5
          transform "normal"
          position x=0 y=0
      }

      switch-events {
          lid-close { spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock"; }
      }
    '';
    "hypr/hyprland-host.conf".text = ''
      bind=SUPER, L, exec, hyprlock

      exec-once=pactl-listener
      exec-once=xrdb -merge <<< 'Xft.dpi: 144'

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

  programs.steam.gamescopeSession.args = [
    "-W"
    "2880"
    "-H"
    "1800"
    "-r"
    "60"
  ];

  system.stateVersion = "24.11";
}
