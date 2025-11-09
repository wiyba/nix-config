[
  ({ pkgs, lib, ... }: 

  {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Gruvbox-Material-Dark";
        package = pkgs.gruvbox-material-gtk-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      gtk2.extraConfig = ''
        gtk-theme-name="Gruvbox-Material-Dark"
        gtk-icon-theme-name="Papirus-Dark"
        gtk-application-prefer-dark-theme=1
      '';
      
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    qt = {
      enable = true;
      style.name = "gtk";
    };

    home.pointerCursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      gtk.enable = true;
      x11.enable = true;
    };
  })
]