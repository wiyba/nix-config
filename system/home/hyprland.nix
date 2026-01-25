{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprlandPackages = with pkgs; [
    swaynotificationcenter
    sway-audio-idle-inhibit
    wlogout
    swww
    dex
    hyprpaper
    hyprlock
    hypridle
    waybar
    polkit_gnome
  ];
in
{
  options = {
    hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    home.packages = hyprlandPackages;

    xdg.configFile = {
      "electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      systemd.variables = [ "--all" ];

      settings = {
        exec = "hyprctl dispatch submap global";
        submap = "global";

        "ecosystem:no_update_news" = true;

        xwayland = {
          force_zero_scaling = true;
        };

        monitor = lib.mkDefault [
          ",preferred,auto,1"
        ];

        env = [
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "QT_QPA_PLATFORM,wayland"
          "QT_QPA_PLATFORMTHEME,kde"
          "XDG_MENU_PREFIX,plasma-"
          "TERMINAL,kitty -1"
        ];

        exec-once = [
          "hypridle"
          "hyprpaper"
          "swaync"
          "waybar"
          "dbus-update-activation-environment --all"
          "sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "sway-audio-idle-inhibit"
          "pactl-listner"
          "bitwarden-handler"
          "polkit-gnome-authentication-agent-1"
        ];

        "$mainMod" = "SUPER";
        "$altMod" = "ALT_L";
        "$launcher" = "fuzzel";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$browser" = "firefox-beta";
        "$editor" = "vscode";
        "$lock" = "hyprlock";
        "$closeSpecial" = "close-special-workspace";

        general = {
          gaps_in = 5;
          gaps_out = 20;
          gaps_workspaces = 0;
          border_size = 2;
          "col.active_border" = "rgba(928374ff) rgba(a89984ff) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = true;
          no_focus_fallback = true;
          allow_tearing = true;

          snap = {
            enabled = true;
            window_gap = 4;
            monitor_gap = 5;
            respect_gaps = true;
          };
        };

        dwindle = {
          preserve_split = true;
          smart_split = false;
          smart_resizing = false;
        };

        decoration = {
          rounding = 4;

          blur = {
            enabled = false;
            xray = true;
            special = false;
            new_optimizations = true;
            size = 14;
            passes = 3;
            brightness = 1;
            noise = 0.04;
            contrast = 1;
            popups = true;
            popups_ignorealpha = 0.6;
            input_methods = true;
            input_methods_ignorealpha = 0.8;
          };

          shadow = {
            enabled = false;
            ignore_window = true;
            range = 30;
            offset = "0 2";
            render_power = 4;
            color = "rgba(00000010)";
          };

          dim_inactive = false;
          dim_strength = 0.025;
          dim_special = 0.07;
        };

        animations = {
          enabled = true;

          bezier = [
            "expressiveFastSpatial, 0.42, 1.67, 0.21, 0.90"
            "expressiveSlowSpatial, 0.39, 1.29, 0.35, 0.98"
            "expressiveDefaultSpatial, 0.38, 1.21, 0.22, 1.00"
            "emphasizedDecel, 0.05, 0.7, 0.1, 1"
            "emphasizedAccel, 0.3, 0, 0.8, 0.15"
            "standardDecel, 0, 0, 0, 1"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.52, 0.03, 0.72, 0.08"
          ];

          animation = [
            "windowsIn, 1, 3, emphasizedDecel, popin 80%"
            "windowsOut, 1, 2, emphasizedDecel, popin 90%"
            "windowsMove, 1, 3, emphasizedDecel, slide"
            "border, 1, 10, emphasizedDecel"
            "layersIn, 1, 2.7, emphasizedDecel, popin 93%"
            "layersOut, 1, 2.4, menu_accel, popin 94%"
            "fadeLayersIn, 1, 0.5, menu_decel"
            "fadeLayersOut, 1, 2.7, menu_accel"
            "workspaces, 1, 7, menu_decel, slide"
            "specialWorkspaceIn, 1, 2.8, emphasizedDecel, slidevert"
            "specialWorkspaceOut, 1, 1.2, emphasizedAccel, slidevert"
          ];
        };

        input = {
          kb_layout = "us, ru";
          kb_options = "grp:alt_shift_toggle";
          numlock_by_default = true;
          repeat_delay = 250;
          repeat_rate = 35;
          follow_mouse = 1;
          off_window_axis_events = 2;
          mouse_refocus = false;
          sensitivity = 0.2;
          accel_profile = "flat";

          touchpad = {
            scroll_factor = 0.5;
            tap-to-click = false;
            natural_scroll = true;
            disable_while_typing = false;
          };
        };

        gesture = [
          "3, horizontal, workspace"
        ];

        gestures = {
          workspace_swipe_distance = 550;
          workspace_swipe_cancel_ratio = 0.2;
          workspace_swipe_min_speed_to_force = 5;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          background_color = "rgba(101418FF)";
          vfr = 1;
          vrr = 0;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          enable_swallow = false;
          swallow_regex = "(foot|kitty|allacritty|Alacritty)";
          allow_session_lock_restore = true;
          session_lock_xray = true;
          initial_workspace_tracking = false;
          focus_on_activate = true;
        };

        binds = {
          scroll_event_delay = 0;
          hide_special_on_workspace_change = true;
        };

        cursor = {
          zoom_factor = 1;
          zoom_rigid = false;
          hotspot_padding = 1;
        };

        bind = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86SelectiveScreenshot, exec, grim -g \"$(slurp)\" - | wl-copy"
          ", Print, exec, grim - | wl-copy"

          "$mainMod, Q, killactive"
          "$mainMod, V, togglefloating"
          "$mainMod, J, togglesplit"
          "$mainMod, P, pseudo"
          "$mainMod, C, centerwindow"
          "$mainMod, F, fullscreen"
          "$mainMod, M, exit"

          "$mainMod, RETURN, exec, $terminal"
          "$mainMod, SPACE, exec, pgrep fuzzel && pkill fuzzel || fuzzel"
          "SUPER_SHIFT, RETURN, exec, $terminal --class kitty-float"
          "$mainMod, L, exec, $lock"
          "$mainMod, B, exec, $browser"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, N, exec, kitty bash -c \"cd /etc/nixos && nvim -c 'lua require(\\\"persistence\\\").load()'\""

          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mainMod, S, exec, grim - | wl-copy"

          "$mainMod SHIFT, B, exec, ~/.config/hypr/scripts/reload-hyprpaper.sh"
          "$mainMod SHIFT, L, exec, ~/.config/hypr/scripts/reload-hypridle.sh"
          "$mainMod SHIFT, W, exec, ~/.config/hypr/scripts/reload-waybar.sh"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod, 1, exec, $closeSpecial; hyprctl dispatch workspace 1"
          "$mainMod, 2, exec, $closeSpecial; hyprctl dispatch workspace 2"
          "$mainMod, 3, exec, $closeSpecial; hyprctl dispatch workspace 3"
          "$mainMod, 4, exec, $closeSpecial; hyprctl dispatch workspace 4"
          "$mainMod, 5, exec, $closeSpecial; hyprctl dispatch workspace 5"
          "$mainMod, 6, exec, $closeSpecial; hyprctl dispatch workspace 6"
          "$mainMod, 7, exec, $closeSpecial; hyprctl dispatch workspace 7"
          "$mainMod, 8, exec, $closeSpecial; hyprctl dispatch workspace 8"
          "$mainMod, 9, exec, $closeSpecial; hyprctl dispatch workspace 9"
          "$mainMod, 0, exec, $closeSpecial; hyprctl dispatch workspace 10"

          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          "$mainMod, A, togglespecialworkspace, magic"
          "$mainMod SHIFT, A, movetoworkspace, special:magic"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, TAB, workspace, e+1"
          "SHIFT + $mainMod, TAB, workspace, e-1"
          "$altMod, TAB, exec, hyprctl dispatch cyclenext"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrulev2 = [
          "noblur, class:^()$, title:^()$"

          "center, title:^(Open File)(.*)$"
          "float, title:^(Open File)(.*)$"
          "center, title:^(Select a File)(.*)$"
          "float, title:^(Select a File)(.*)$"
          "center, title:^(Choose wallpaper)(.*)$"
          "float, title:^(Choose wallpaper)(.*)$"
          "size 60% 65%, title:^(Choose wallpaper)(.*)$"
          "center, title:^(Open Folder)(.*)$"
          "float, title:^(Open Folder)(.*)$"
          "center, title:^(Save As)(.*)$"
          "float, title:^(Save As)(.*)$"
          "center, title:^(Library)(.*)$"
          "float, title:^(Library)(.*)$"
          "center, title:^(File Upload)(.*)$"
          "float, title:^(File Upload)(.*)$"
          "center, title:^(.*)(wants to save)$"
          "float, title:^(.*)(wants to save)$"
          "center, title:^(.*)(wants to open)$"
          "float, title:^(.*)(wants to open)$"
          "float, class:^(blueberry\\.py)$"
          "float, class:^(guifetch)$"
          "float, class:^(pavucontrol)$"
          "size 45%, class:^(pavucontrol)$"
          "center, class:^(pavucontrol)$"
          "stayfocused, class:^(pavucontrol)$"
          "float, class:^(nmtui)$"
          "size 45%, class:^(nmtui)$"
          "center, class:^(nmtui)$"
          "stayfocused, class:^(nmtui)$"
          "float, class:^(org.pulseaudio.pavucontrol)$"
          "size 45%, class:^(org.pulseaudio.pavucontrol)$"
          "center, class:^(org.pulseaudio.pavucontrol)$"
          "stayfocused, class:^(org.pulseaudio.pavucontrol)$"
          "float, class:^(.blueman-manager-wrapped)$"
          "size 45%, class:^(.blueman-manager-wrapped)$"
          "center, class:^(.blueman-manager-wrapped)$"
          "stayfocused, class:^(.blueman-manager-wrapped)$"
          "float, class:^(nm-connection-editor)$"
          "size 45%, class:^(nm-connection-editor)$"
          "center, class:^(nm-connection-editor)$"
          "float, class:.*plasmawindowed.*"
          "float, class:kcm_.*"
          "float, class:.*bluedevilwizard"
          "float, title:.*Welcome"
          "float, title:^(illogical-impulse Settings)$"
          "float, title:.*Shell conflicts.*"
          "float, class:org.freedesktop.impl.portal.desktop.kde"
          "size 60% 65%, class:org.freedesktop.impl.portal.desktop.kde"
          "float, class:^(Zotero)$"
          "size 45%, class:^(Zotero)$"

          "float, class:^(plasma-changeicons)$"
          "noinitialfocus, class:^(plasma-changeicons)$"
          "move 999999 999999, class:^(plasma-changeicons)$"
          "move 40 80, title:^(Copying — Dolphin)$"

          "tile, class:^dev\\.warp\\.Warp$"

          "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
          "keepaspectratio, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
          "move 73% 72%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
          "size 25%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
          "pin, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"

          "immediate, title:.*\\.exe"
          "immediate, title:.*minecraft.*"
          "immediate, class:^(steam_app).*"

          "noshadow, floating:0"

          "idleinhibit always, fullscreenstate:* 2, focus:1"

          "float, class:^(firefox-beta)$, title:.*Bitwarden.*"
        ];

        workspace = [
          "special:special, gapsout:30"
        ];

        layerrule = [
          "xray on, match:namespace .*"

          "no_anim on, match:namespace walker"
          "no_anim on, match:namespace selection"
          "no_anim on, match:namespace overview"
          "no_anim on, match:namespace anyrun"
          "no_anim on, match:namespace indicator.*"
          "no_anim on, match:namespace osk"
          "no_anim on, match:namespace hyprpicker"
          "no_anim on, match:namespace noanim"
          "no_anim on, match:namespace gtk4-layer-shell"

          "blur on, match:namespace gtk-layer-shell"
          "ignore_alpha 0, match:namespace gtk-layer-shell"
          "blur on, match:namespace launcher"
          "ignore_alpha 0.5, match:namespace launcher"
          "blur on, match:namespace notifications"
          "ignore_alpha 0.69, match:namespace notifications"
          "blur on, match:namespace logout_dialog"

          "animation slide left, match:namespace sideleft.*"
          "animation slide right, match:namespace sideright.*"
          "blur on, match:namespace session[0-9]*"
          "blur on, match:namespace bar[0-9]*"
          "ignore_alpha 0.6, match:namespace bar[0-9]*"
          "blur on, match:namespace barcorner.*"
          "ignore_alpha 0.6, match:namespace barcorner.*"
          "blur on, match:namespace dock[0-9]*"
          "ignore_alpha 0.6, match:namespace dock[0-9]*"
          "blur on, match:namespace indicator.*"
          "ignore_alpha 0.6, match:namespace indicator.*"
          "blur on, match:namespace overview[0-9]*"
          "ignore_alpha 0.6, match:namespace overview[0-9]*"
          "blur on, match:namespace cheatsheet[0-9]*"
          "ignore_alpha 0.6, match:namespace cheatsheet[0-9]*"
          "blur on, match:namespace sideright[0-9]*"
          "ignore_alpha 0.6, match:namespace sideright[0-9]*"
          "blur on, match:namespace sideleft[0-9]*"
          "ignore_alpha 0.6, match:namespace sideleft[0-9]*"
          "blur on, match:namespace osk[0-9]*"
          "ignore_alpha 0.6, match:namespace osk[0-9]*"
        ];
      };
    };

    services.hypridle.enable = true;

    programs.hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          path = "screenshot";
          blur_passes = 5;
          blur_size = 4;
          noise = 0.0;
          contrast = 0.7;
          brightness = 0.8172;
          vibrancy = 0.2;
          vibrancy_darkness = 0.0;
        };

        image = {
          monitor = "";
          path = "/var/lib/AccountsService/icons/$USER";
          size = 130;
          rounding = -1;
          border_size = 0;
          border_color = "rgba(255, 255, 255, 0.1)";
          rotate = 0;
          reload_time = -1;
          position = "0, -50";
          halign = "center";
          valign = "center";
        };

        input-field = {
          monitor = "";
          size = "300, 45";
          outline_thickness = 1;
          dots_size = 0.1;
          dots_spacing = 0.64;
          dots_center = true;
          outer_color = "rgba(255, 255, 255, 0.2)";
          inner_color = "rgba(255, 255, 255, 0.05)";
          font_color = "rgba(255, 255, 255, 0.9)";
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "<span foreground=\"##ffffff40\">Enter Password</span>";
          hide_input = false;
          rounding = 25;
          check_color = "rgba(204, 136, 34, 0)";
          fail_color = "rgba(204, 34, 34, 0)";
          fail_text = "<span foreground=\"##ff6b6b\">Authentication Failed</span>";
          position = "0, -180";
          halign = "center";
          valign = "center";
        };

        label = [
          {
            monitor = "";
            text = "cmd[update:86400000] zsh -c 'LC_TIME=C date \"+%A\"'";
            color = "rgba(255, 255, 255, 0.5)";
            font_size = 84;
            font_family = "Fira Semibold";
            position = "0, 270";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:60000] zsh -c 'LC_TIME=C date \"+%-d %B, %Y\" | sed \"s/./& /g\" | sed \"s/ $//\"'";
            color = "rgba(255, 255, 255, 0.7)";
            font_size = 20;
            font_family = "Fira Semibold";
            position = "0, 170";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:1000] zsh -c 'date \"+%-H:%M\" | sed \"s/./& /g\" | sed \"s/ $//\"'";
            color = "rgba(255, 255, 255, 0.7)";
            font_size = 16;
            font_family = "Fira Semibold";
            position = "0, 110";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:30000] zsh -c 'echo $USER'";
            color = "rgba(255, 255, 255, 0.45)";
            font_size = 16;
            font_family = "Fira Semibold";
            position = "50, 80";
            halign = "left";
            valign = "bottom";
          }
          {
            monitor = "";
            text = "cmd[update:30000] zsh -c 'uname -n'";
            color = "rgba(255, 255, 255, 0.4)";
            font_size = 16;
            font_family = "Fira Semibold";
            position = "50, 30";
            halign = "left";
            valign = "bottom";
          }
          {
            monitor = "";
            text = "cmd[update:60000] bash -c 'echo \"$(LC_ALL=C uptime | sed -nE \"s/.* up +([^,]*),.*/\\1/p\")\" up'";
            color = "rgba(255, 255, 255, 0.4)";
            font_size = 16;
            font_family = "Fira Semibold";
            position = "-50, 80";
            halign = "right";
            valign = "bottom";
          }
          {
            monitor = "";
            text = "cmd[update:10000] zsh -c 'echo \"$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | sed \"s/$/%/\")\" charged'";
            color = "rgba(255, 255, 255, 0.4)";
            font_size = 16;
            font_family = "Fira Semibold";
            position = "-50, 30";
            halign = "right";
            valign = "bottom";
          }
        ];

        auth = {
          "pam:enabled" = true;
          "pam:module" = "hyprlock";
          "fingerprint:enabled" = true;
          "fingerprint:ready_message" = "Scan fingerprint to unlock";
          "fingerprint:present_message" = "Scanning fingerprint";
          "fingerprint:retry_delay" = 250;
        };
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = [ "/etc/nixos/imgs/gruvbox-dark-blue.png" ];
      };
    };
  };
}
