{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
        user = "wiyba";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd uwsm start hyprland-uwsm.desktop";
        user = "greeter";
      };
    };
  };
}
