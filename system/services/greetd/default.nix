{ pkgs, config, wm, ... }:

let
  sessionCmd = {
    hyprland = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
    niri = "${pkgs.niri}/bin/niri-session";
  }.${wm};
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd '${sessionCmd}' --remember --remember-session";
        user = "greeter";
      };
    };
  };
}
