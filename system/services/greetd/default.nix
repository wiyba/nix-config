{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {                                                                                                          
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd '${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop' --remember --remember-session";                                                                                                             
        user = "greeter";                                                                                                         
      };
    };
  };
}
