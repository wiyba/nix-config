{
  config,
  pkgs,
  lib,
  ...
}:
let
  kdePackages = with pkgs.kdePackages; [
    # kate
    # filelight
    # discover
    # dolphin
    # ark
    # okular
    # gwenview
    # spectacle
  ];
in
{
  options = {
    plasma.enable = lib.mkEnableOption "Enable KDE Plasma";
  };

  config = lib.mkIf config.plasma.enable {
    home.packages = kdePackages;

    xdg.configFile."electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
    '';
  };
}
