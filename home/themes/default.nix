[
  ({ pkgs, lib, ... }:

  let
    catppuccinFausto = pkgs.stdenv.mkDerivation rec {
      pname = "catppuccin-gtk-fausto";
      version = "2024-05-21";

      src = pkgs.fetchFromGitHub {
        owner = "Fausto-Korpsvart";
        repo = "Catppuccin-GTK-Theme";
        rev = "449a4c90dbe3a2305de06ed68edb81f360cfecfa";
        sha256 = "sha256-41Ng86gV7It0BkxCvA0c7QOIx0szpMwCdBaGWu+iJ+A=";
      };

      propagatedBuildInputs = with pkgs; [
        gtk-engine-murrine
        gnome-themes-extra
      ];

      installPhase = ''
        mkdir -p $out/share/themes
        cp -r themes/Catppuccin-Frappe-Standard-Blue-Dark $out/share/themes/
      '';
    };
  in

  {
    gtk = rec {
      enable = true;

      theme = {
        name = "Catppuccin-Frappe-Standard-Blue-Dark";
        package = catppuccinFausto;
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
          @import "${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css";
        '';
      };
    };
  })
]
