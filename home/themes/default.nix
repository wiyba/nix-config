[
  ({ pkgs, ... }: {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      iconTheme = {
        name = "breeze-dark";
        package = pkgs.kdePackages.breeze-icons;
      };

      cursorTheme = {
        name = "breeze_cursors";
        package = pkgs.kdePackages.breeze;
        size = 24;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "Breeze";
    };

    home.pointerCursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  })
]
