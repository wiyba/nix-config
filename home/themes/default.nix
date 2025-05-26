[
  { pkgs, ... }: {
    gtk = rec {
      enable = true;
  
      theme = {
        name = "Catppuccin-Frappe-Standard-Blue-Dark";
        package = pkgs.catppuccin-gtk;
      };
  
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
  
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  
      gtk4 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        extraCss = ''
          @import url("file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css");
        '';
      };
    };
  }
]
