{ lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = [
      {
        height = 36;
        spacing = 5;
        "margin-top" = 10;
        "margin-right" = 10;
        "margin-left" = 10;

        "modules-left" = [
          "hyprland/workspaces"
        ];

        "modules-center" = [
          "clock#time"
          "clock#date"
          "custom/weather"
        ];

        "modules-right" = [
          "network"
          "bluetooth"
          "hyprland/language"
          "pulseaudio"
          "backlight"
          "battery"
          "tray"
        ];

        "custom/weather" = {
          format = "{}";
          interval = 300;
          exec = "get-weather";
          tooltip = false;
        };

        tray = {
          spacing = 10;
        };

        "clock#date" = {
          format = "  {:%a, %d %b}";
          tooltip = false;
        };

        "clock#time" = {
          format = "  {:%H:%M}";
          tooltip = false;
        };

        backlight = {
          format = "󰃠  {percent}%";
          tooltip = false;
        };

        battery = {
          states = {
            warning = 20; };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-warning = "󰂃 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format = "power:\t{power}\ntime:\t{time}\ncycles:\t{cycles}\nhealth\t{health}";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ifname}";
          format-disconnected = "  DISC";
          format-alt = "  {ipaddr}";
          tooltip-format = "ifname:\t{ifname}\nipaddr:\t{ipaddr}\nmask:\t{netmask}\ngwaddr:\t{gwaddr}\nessid:\t{essid}\nfreq:\t{frequency} GHz\nsignal:\t{signaldBm} dBm";
        };

        bluetooth = {
          format = "󰂯  {status}";
          format-connected = "󰂯  {device_alias}";
          format-connected-battery = "󰂯  {device_alias}";
          format-on = "󰂯  DISC";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };

        "hyprland/language" = {
            format = "  {}";
            format-en = "US";
            format-ru = "RU";
            keyboard-name = "at-translated-set-2-keyboard";
        };

        pulseaudio = {
          format = "  {volume}%";
          format-muted = "  MUTED";
          format-bluetooth = "  {volume}%";
          format-bluetooth-muted = "  MUTED";
          on-click = "pavucontrol";
          tooltip = false;
        };
      }
    ];
    style = builtins.readFile ./style.css;
  };
}
