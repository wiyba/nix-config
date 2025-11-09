{ config, pkgs, lib, ... }:
let
  nerdFonts = with pkgs.nerd-fonts; [
    symbols-only
    caskaydia-cove
  ];
  
  fontPkgs = with pkgs; [
    font-awesome
    material-design-icons
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ] ++ nerdFonts;
  
  packages = with pkgs; [
    age
    sops
    unzip
    zip
    wl-clipboard 
    brightnessctl
    pavucontrol
    easyeffects
    mpc
    rmpc
    telegram-desktop
    equibop
    socat
    statix
    ruff
    filezilla
    vscode
    nil
    direnv
  ];
  
  kdePackages = with pkgs.kdePackages; [
    kate
    filelight
    discover
    dolphin
    ark
    okular
    gwenview
    spectacle
  ];
in
{
  options = {
    plasma.enable = lib.mkEnableOption "Enable KDE Plasma";
  };

  config = lib.mkIf config.plasma.enable {
    home.packages = fontPkgs ++ packages ++ kdePackages;

    fonts.fontconfig.enable = true;

    xdg.configFile."electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
    '';
  };
}