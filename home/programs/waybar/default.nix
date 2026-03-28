{ host, ... }:
let
  modules = {
    home = [
      "custom/proxy"
      "network"
      "hyprland/language"
      "pulseaudio"
      "tray"
    ];
    thinkpad = [
      "custom/proxy"
      "network"
      "bluetooth"
      "hyprland/language"
      "pulseaudio"
      "battery"
      "tray"
    ];
  };
  monitors = {
    home = "DP-1";
    thinkpad = "eDP-1";
  };
in
{
  programs.waybar = {
    enable = true;
    settings = [
      {
        output = monitors.${host};
        height = 36;
        spacing = 5;
        "margin-top" = 10;
        "margin-right" = 10;
        "margin-left" = 10;

        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        "modules-center" = [
          "clock#time"
          "clock#date"
          "custom/weather"
        ];

        "modules-right" = modules.${host};

        "custom/weather" = {
          interval = 10;
          exec = "get-weather";
          return-type = "json";
        };

        "custom/proxy" = {
          interval = 5;
          exec = "proxy-status";
          on-click = "proxy-toggle";
          return-type = "json";
          tooltip = false;
          hide-empty-text = true;
        };

        tray = {
          spacing = 10;
          ignored-items = [
            "blueman-applet"
            "nm-applet"
            ".blueman-applet-wrapped"
          ];
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
            warning = 20;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-warning = "󰂃 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip-format = "power:\t{power}\ntime:\t{time}\ncycles:\t{cycles}\nhealth\t{health}";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ifname}";
          format-disconnected = "󰪎  DISC";
          on-click = "kitty --class nmtui nmtui";
          tooltip-format = "ifname:\t{ifname}\nipaddr:\t{ipaddr}\nmask:\t{netmask}\ngwaddr:\t{gwaddr}\nessid:\t{essid}\nfreq:\t{frequency} GHz\nsignal:\t{signaldBm} dBm";
        };

        bluetooth = {
          format = "󰂯  {status}";
          format-connected = "󰂯  {device_alias}";
          format-connected-battery = "󰂯  {device_alias}";
          format-on = "󰂲  DISC";
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
        };

        "hyprland/window" = {
          format = "{class}";
          # rewrite = {};

        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰖁  MUTED";
          format-bluetooth = "{icon}  {volume}%";
          format-bluetooth-muted = "󰖁  MUTED";
          on-click = "pwvucontrol";
          format-icons = {
            default = [
              "󰕿"
              "󰕿"
              "󰕿"
              "󰕿"
              "󰖀"
              "󰖀"
              "󰖀"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
              "󰕾"
            ];
          };
          tooltip = false;
        };
      }
    ];
    style = builtins.readFile ./style.css;
  };
}
