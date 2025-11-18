[
  (
    { pkgs, lib, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        gtk2.extraConfig = ''
          gtk-application-prefer-dark-theme=1
        '';
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      };
      qt = {
        enable = true;
        style.name = "fusion";
      };
      home.pointerCursor = {
        name = "breeze_cursors";
        package = pkgs.kdePackages.breeze;
        gtk.enable = true;
        x11.enable = true;
      };
    }
  )
]
