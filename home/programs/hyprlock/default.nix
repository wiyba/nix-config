{ pkgs, ... }:

let
  musicProgressScript = pkgs.writeShellScript "music-progress.sh" (builtins.readFile ./music-progress.sh);
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
in {
  home.packages = with pkgs; [
    hyprlock
    playerctl
  ];

  xdg.configFile."hypr/hyprlock.conf".text = ''
    ########################################
    ###  Hyprlock Configuration (NixOS)  ###
    ########################################

    background {
        monitor =
        path = screenshot
        blur_passes = 5
        blur_size = 4
        noise = 0.0
        contrast = 0.7
        brightness = 0.8172
        vibrancy = 0.2
        vibrancy_darkness = 0.0
    }

    image {
        monitor =
        path = /var/lib/AccountsService/icons/$USER
        size = 130
        rounding = -1
        border_size = 0
        border_color = rgba(255, 255, 255, 0.1)
        rotate = 0
        reload_time = -1
        position = 0, -50
        halign = center
        valign = center
    }

    input-field {
        monitor =
        size = 300, 45
        outline_thickness = 1
        dots_size = 0.1
        dots_spacing = 0.64
        dots_center = true
        outer_color = rgba(255, 255, 255, 0.2)
        inner_color = rgba(255, 255, 255, 0.05)
        font_color = rgba(255, 255, 255, 0.9)
        fade_on_empty = false
        fade_timeout = 1000
        placeholder_text = <span foreground="##ffffff40">Enter Password</span>
        hide_input = false
        rounding = 25
        check_color = rgba(204, 136, 34, 0)
        fail_color = rgba(204, 34, 34, 0)
        fail_text = <span foreground="##ff6b6b">Authentication Failed</span>
        position = 0, -180
        halign = center
        valign = center
    }

    # MUSIC PROGRESS BAR
    label {
        monitor =
        text = cmd[update:1000] ${musicProgressScript}
        font_size = 16
        font_family = "Fira Semibold"
        color = rgba(255, 255, 255, 0.8)
        position = 0, -330
        halign = center
        valign = center
}

    # MUSIC ARTIST + TITLE
    label {
        monitor =
        text = cmd[update:2000] bash -c 'artist=$(${playerctlBin} metadata artist 2>/dev/null); title=$(${playerctlBin} metadata title 2>/dev/null); if [ -n "$artist" ] && [ -n "$title" ]; then artist_spaced=$(printf " %s" "$artist" | sed "s/./& /g"); title_spaced=$(printf "%s " "$title" | sed "s/./& /g"); printf "╔══════════════════╗ ║  %s  -  %s  ║ ╚══════════════════╝\n" "$artist_spaced" "$title_spaced"; else echo "Nothing Playing"; fi'
        font_size = 16
        font_family = "Fira Semibold"
        color = rgba(255, 255, 255, 0.8)
        position = 0, -420
        halign = center
        valign = center
    }

    # DAY OF WEEK
    label {
        monitor =
        text = cmd[update:86400000] zsh -c 'LC_TIME=C date "+%A"'        
        color = rgba(255, 255, 255, 0.5)
        font_size = 84
        font_family = "Fira Semibold"
        position = 0, 270
        halign = center
        valign = center
    }

    # DATE
    label {
        monitor =
        text = cmd[update:60000] zsh -c 'LC_TIME=C date "+%-d %B, %Y" | sed "s/./& /g" | sed "s/ $//"'
        color = rgba(255, 255, 255, 0.7)
        font_size = 20
        font_family = "Fira Semibold"
        position = 0, 170
        halign = center
        valign = center
    }

    # TIME
    label {
        monitor =
        text = cmd[update:1000] zsh -c 'date +"- %-H:%M -" | sed "s/./& /g" | sed "s/ $//"'
        color = rgba(255, 255, 255, 0.9)
        font_size = 16
        font_family = "Fira Semibold"
        position = 0, 110
        halign = center
        valign = center
    }

    # USERNAME
    label {
        monitor =
        text = cmd[update:30000] zsh -c 'echo $USER'
        color = rgba(255, 255, 255, 0.45)
        font_size = 16
        font_family = "Fira Semibold"
        position = 50, 80
        halign = left
        valign = bottom
    }

    # HOSTNAME
    label {
        monitor =
        text = cmd[update:30000] zsh -c 'uname -n'
        color = rgba(255, 255, 255, 0.4)
        font_size = 16
        font_family = "Fira Semibold"
        position = 50, 30
        halign = left
        valign = bottom
    }

    # UPTIME
    label {
        monitor =
        text = cmd[update:60000] bash -c 'LC_ALL=C uptime | sed -nE "s/.* up +([^,]*),.*/\1/p"'
        color = rgba(255, 255, 255, 0.4)
        font_size = 16
        font_family = "Fira Semibold"
        position = -50, 80
        halign = right
        valign = bottom
    }

    # BATTERY
    label {
        monitor =
        text = cmd[update:10000] zsh -c 'cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | sed "s/$/%/" || echo ""'
        color = rgba(255, 255, 255, 0.4)
        font_size = 16
        font_family = "Fira Semibold"
        position = -50, 30
        halign = right
        valign = bottom
    }

    auth {
        pam:enabled = true
        pam:module = hyprlock
    
        fingerprint:enabled = true
        fingerprint:ready_message = Scan fingerprint to unlock
        fingerprint:present_message = Scanning fingerprint
        fingerprint:retry_delay = 250
    }
  '';
}

