[
  ({ pkgs, ... }: 
  
  {
    gtk = {
      enable = true;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };
  })
]
