{ lib, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "CaskaydiaCove Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      enable_audio_bell = "no";
      font_size = 12.0;
      window_padding_width = 25;
      background_opacity = 1.0;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
    };

    extraConfig = ''
      cursor_shape beam
      cursor_trail 1

      map ctrl+c copy_or_interrupt

      map ctrl+f launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id
      map kitty_mod+f launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id

      map page_up scroll_page_up
      map page_down scroll_page_down

      map ctrl+plus change_font_size all +1
      map ctrl+equal change_font_size all +1
      map ctrl+kp_add change_font_size all +1
      map ctrl+minus change_font_size all -1
      map ctrl+underscore change_font_size all -1
      map ctrl+kp_subtract change_font_size all -1
      map ctrl+0 change_font_size all 0
      map ctrl+kp_0 change_font_size all 0

      background #282828
      foreground #ebdbb2

      cursor #928374

      selection_foreground #928374
      selection_background #3c3836

      color0 #282828
      color8 #928374

      color1 #cc241d
      color9 #fb4934

      color2 #98971a
      color10 #b8bb26

      color3 #d79921
      color11 #fabd2d

      color4 #458588
      color12 #83a598

      color5 #b16286
      color13 #d3869b

      color6 #689d6a
      color14 #8ec07c

      color7 #a89984
      color15 #928374
    '';
  };
}
