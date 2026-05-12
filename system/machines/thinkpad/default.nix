{ pkgs
, lib
, inputs
, ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../services/mihomo
  ];

  boot = {
    initrd = {
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
  };

  systemd.network.links = {
    "10-wlan0" = {
      matchConfig.MACAddress = "40:c7:3c:d0:97:15";
      linkConfig.Name = "wlan0";
    };
  };

  networking = {
    hostName = "thinkpad";
    useDHCP = false;

    networkmanager = {
      enable = true;
      dispatcherScripts = [
        {
          type = "basic";
          source = pkgs.writeShellScript "link-policy" ''
            target="wiyba_net"
            case "$2" in
              up)
                if [ "$CONNECTION_ID" = "$target" ]; then
                  ${pkgs.systemd}/bin/systemctl stop mihomo.service
                else
                  ${pkgs.systemd}/bin/systemctl start mihomo.service
                fi
                ;;
            esac
          '';
        }
      ];
      ensureProfiles.profiles = {
        cdc-wdm0 = {
          connection = {
            id = "cdc-wdm0";
            type = "gsm";
            autoconnect = true;
          };
          gsm.auto-config = true;
          ipv4 = {
            method = "auto";
            dns = "1.1.1.1;9.9.9.9;77.88.8.8;";
            ignore-auto-dns = "true";
          };
          ipv6 = {
            method = "auto";
            never-default = true;
          };
        };

        hotspot = {
          connection = {
            id = "hotspot";
            type = "wifi";
            interface-name = "wlan0";
            autoconnect = false;
          };
          wifi = {
            mode = "ap";
            ssid = "osint10";
            band = "bg";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "13371337";
          };
          ipv4 = {
            address1 = "10.0.0.1/24";
            method = "shared";
          };
          ipv6.method = "ignore";
        };
      };
    };

    modemmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 2222 ];
      allowedUDPPorts = [
        67
        53
      ];
    };

    nat = {
      enable = true;
      externalInterface = "wwp0s20f0u8";
      internalInterfaces = [ "wlan0" ];
    };
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
      description = "fprint fix after resume";
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
      description = "modemmanager fix after resume";
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
    mihomo-fix = {
      description = "mihomo fix after resume";
      wantedBy = [ "post-resume.target" ];
      after = [ "post-resume.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "link-policy-resume" ''
          target="wiyba_net"
          sleep 5
          active="$(${pkgs.networkmanager}/bin/nmcli -t -f NAME c show --active | ${pkgs.coreutils}/bin/head -1)"
          if [ "$active" = "$target" ]; then
            ${pkgs.systemd}/bin/systemctl stop mihomo.service
          else
            ${pkgs.systemd}/bin/systemctl start mihomo.service
          fi
        '';
      };
    };
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="AC", \
      RUN+="${pkgs.systemd}/bin/systemctl --no-block --machine=wiyba@.host --user start niri-refresh-switch.service"
  '';

  environment.systemPackages = with pkgs; [
    brightnessctl
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

      PLATFORM_PROFILE_ON_BAT = "low-power";

      PCIE_ASPM_ON_BAT = "powersupersave";

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  home-manager.users.wiyba.systemd.user.services.niri-refresh-switch = {
    Unit.Description = "Refresh niri output mode on power state change";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.nix-profile/bin/niri-refresh-switch";
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
