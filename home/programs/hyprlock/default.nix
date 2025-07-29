{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprlock ];

  xdg.configFile."hypr/hyprlock.conf".text = ''
    ### Wallpaper configuration
    $1 = ${../../../imgs/42271.jpg}
    $1 = ${../../../imgs/42271.jpg}
    $2 = ${../../../imgs/new.jpeg}
    $3 = ${../../../imgs/b24.png}
    $4 = ${../../../imgs/new.jpeg}
    $5 = ${../../../imgs/img19.jpg}
    $current = $5

    background {
        monitor =
        path = $current
    }

    input-field {
        monitor =
        size = 200, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1
        outer_color = rgb(48, 52, 70)
        inner_color = rgb(198, 208, 245)
        font_color = rgb(48, 52, 70)
        fade_on_empty = true
        fade_timeout = 300
        placeholder_text =
        hide_input = false
        rounding = -1
        check_color = rgb(166, 209, 137)
        fail_color = rgb(231, 130, 132)
        fail_text =
        fail_transition = 200
        capslock_color = -1
        numlock_color = -1
        bothlock_color = -1
        invert_numlock = false
        swap_font_color = false
        position = 0, -20
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$TIME"
        color = rgba(198, 208, 245, 1)
        font_size = 85
        font_family = Fira Semibold
        position = 30, 10
        halign = left
        valign = bottom
        shadow_passes = 5
        shadow_size = 10
    }
  '';
}
