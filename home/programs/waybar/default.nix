{ lib, pkgs, ... }:

let
  weatherScript = pkgs.writeShellScript "weather" (builtins.readFile ./weather.sh);
in {
  programs.waybar = {
    enable = true;

    settings = [
      {
        position = "top";
        height = 40;
        width = 1880;
        margin-top = 10;

        layer = "top";

        modules-left   = [ "custom/menu" "custom/weather" "hyprland/window" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right  = [ "tray" "hyprland/language" "pulseaudio" "clock" "custom/power" ];

        "custom/menu" = {
          format = "{icon}";
          format-icons = "";
          on-click = "ulauncher";
          escape = true;
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            urgent = "";
            active = "";
            default = "";
          };
          tooltip = false;
          "persistent-workspaces" = { "*" = 5; };
        };

        "hyprland/window" = {
          format = "{class}";
          separate-outputs = false;
          "hide-empty-text" = true;
        };

        "custom/weather" = {
          format = "{}";
          interval = 10;
          exec = "${weatherScript}";
          tooltip = false;
        };

        tray = {
          "icon-size" = 18;
          spacing = 10;
        };

        "hyprland/language" = {
          format = "<span color='#fab387'></span> {}";
          "format-en" = "EN";
          "format-ru" = "RU";
          "on-click" = "hyprctl dispatch lang toggle";
        };

        pulseaudio = {
          "scroll-step" = 5;
          format = "<span color='#fab387'>{icon}</span> {volume}%";
          "format-icons" = {
            default = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
          tooltip = false;
        };

        clock = {
          format = "<span color='#fab387'></span> {:%H:%M}";
          "tooltip-format" = "<big><span color='#cdd6f4'>{:%Y %B}</span></big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "<span color='#eba0ac'></span> <span color='#cdd6f4'>{:%d.%m.%Y}</span>";
          calendar = {
            mode = "month";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            format = {
              months = "<span color='#cdd6f4'><b>{}</b></span>";
              days = "<span color='#cdd6f4'><b>{}</b></span>";
              weeks = "<span color='#f5c2e7'><b>W{}</b></span>";
              weekdays = "<span color='#f5c2e7'><b>{}</b></span>";
              today = "<span color='#eba0ac'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            "on-click-right" = "mode";
            "on-click-forward" = "tz_up";
            "on-click-backward" = "tz_down";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };

        "custom/power" = {
          format = "{icon}";
          "format-icons" = "";
          "on-click" = "wlogout";
          escape = true;
          tooltip = false;
        };
      }
    ];

    style = builtins.readFile ./style.css;
    systemd.enable = true;
  };
}
