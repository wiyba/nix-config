{ ... }:

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
      window_padding_width = 15;
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

      include themes/noctalia.conf
    '';
  };
}
