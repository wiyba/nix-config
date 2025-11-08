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
          "pulseaudio"
          "backlight"
          "battery"
          "tray"
        ];

        "custom/weather" = {
          format = "{}";
          interval = 300;
          exec = "gw";
          tooltip = false;
        };

        tray = {
          spacing = 10;
        };

        "clock#date" = {
          format = "  {:%a, %d %b}";
        };

        "clock#time" = {
          format = "  {:%H:%M}";
        };

        backlight = {
          format = "󰳲  {percent}%";
        };

        battery = {
          states = {
            warning = 20;
          };
          format = "{icon} {capacity}%";
          "format-charging" = "󰂄 {capacity}%";
          "format-warning" = "󰂃 {capacity}%";
          "format-icons" = [
            "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"
          ];
        };

        network = {
          "format-wifi" = "  WLAN";
          "format-ethernet" = "  ETH";
          "format-disconnected" = "  DISC";
          "tooltip-format" = "{essid} | {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "  {volume}%";
          "format-muted" = "  MUTED";
          "format-bluetooth" = "  {volume}%";
          "format-bluetooth-muted" = "  MUTED";
          "on-click" = "pavucontrol";
        };
      }
    ];
    style = builtins.readFile ./style.css;
  };
}
