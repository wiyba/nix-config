{ pkgs, ... }:

let
  btopConf = pkgs.writeText "btop.conf" ''
    color_theme = "gruvbox_material_dark"
    theme_background = False
    rounded_corners = True
    proc_sorting = "cpu direct"
    update_ms = 1000
  '';
in
{
  environment.systemPackages = [ pkgs.btop ];

  systemd.tmpfiles.settings."10-btop"."/root/.config/btop/btop.conf"."L+".argument =
    "${btopConf}";
}
