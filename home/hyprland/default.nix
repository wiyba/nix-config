{ pkgs, lib, inputs, ... }:

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
    noto-fonts-emoji
  ] ++ nerdFonts;

  packages = with pkgs; [
    loupe
    appeditor
    swaynotificationcenter
    sway-audio-idle-inhibit
    nemo
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
  ] ++ fontPkgs;

in
{
  imports = lib.concatMap import [
    ./programs
    ./scripts
    ./services
    ./themes
  ];

  home = {
    inherit packages;
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      BROWSER = "${lib.getExe pkgs.firefox-beta}";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };

  fonts.fontconfig.enable = true;

  xdg.configFile = {
    "electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
    '';
    
    "hypr".source = ./config/hyprland;
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "hyprland" ];
      };
      hyprland = {
        default = [ "gtk" "hyprland" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    xdgOpenUsePortal = true;
  };
}
