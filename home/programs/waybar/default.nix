{ lib, ... }:

{
  programs.waybar = {
    enable = true;

    settings = [
      {
        position   = "top";
        height     = 40;
        width      = 1880;
        margin-top = 10;

        include = [ "${./shared.json}" ];

        modules-left   = [ "custom/menu" "custom/weather" "hyprland/window" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right  = [ "tray" "hyprland/language" "pulseaudio" "clock" "custom/power" ];
      }
    ];

    style          = builtins.readFile ./style.css;
    systemd.enable = true;
  };
}
