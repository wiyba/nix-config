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
    loupe
    appeditor
    swaynotificationcenter
    sway-audio-idle-inhibit
    age
    sops
    wlogout
    unzip
    zip
    grim 
    slurp 
    wl-clipboard 
    swww
    brightnessctl
    pavucontrol
    playerctl
    pulsemixer
    dex
    hyprpaper
    hyprlock
    hypridle
    easyeffects
    waybar
    mpc
    rmpc
    telegram-desktop
    equibop
    socat
    statix
    ruff
    filezilla
    networkmanagerapplet
    vscode
    nil
    direnv
    kdePackages.dolphin
    polkit_gnome
  ];
in
{
  options = {
    hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    home.packages = fontPkgs ++ packages;

    fonts.fontconfig.enable = true;

    xdg.configFile = {
      "electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
      "hypr" = {
        source = ./dotfiles/config/hypr;
        recursive = true;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      systemd.variables = ["--all"];
    };
  };
}