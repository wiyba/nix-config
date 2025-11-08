{ pkgs, lib, ... }:


{
  programs = {
    dconf.enable = true;
    hyprland.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [ kitty ];
    variables = { HYPRLAND_DISABLE_VT_SWITCH = "0"; };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };


  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock = {};
  };

  services = {
    blueman.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/Hyprland";
          user = "greeter";
        };
      };
      
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    seatd.enable = true;
  };
}
