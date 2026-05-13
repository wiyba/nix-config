{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      rocmSupport = true;
    };
    settings = {
      color_theme = "gruvbox_material_dark";
      theme_background = false;
      rounded_corners = true;
      proc_sorting = "cpu direct";
      update_ms = 1000;
    };
  };
}
