{ pkgs, lib, ... }:

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

  audioPkgs = with pkgs; [
    pasystray
    pavucontrol
    playerctl
    pulsemixer
  ];

  packages = with pkgs; [
    loupe
    appeditor
    ulauncher
    swaynotificationcenter
    sway-audio-idle-inhibit
    nemo
    wlogout
    unzip
    grim
    slurp
    wl-clipboard
    zip
    papirus-icon-theme
  ] ++ fontPkgs ++ audioPkgs;

  scripts = pkgs.callPackage ./scripts.nix { hyprctl = pkgs.hyprland; jq = pkgs.jq; };

in
{
  imports = [
    ../../shared
    ../../programs/hyprlock
    ../../programs/hyprpaper
    ../../programs/waybar
    ../../programs/kitty
    ../../services/hypridle
  ];

  home = {
    inherit packages;
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.getExe pkgs.zsh}";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

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

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig =
    ''
      $terminal = ${lib.getExe pkgs.kitty}
      $fileManager = ${lib.getExe pkgs.nemo}
      $menu = ${lib.getExe pkgs.ulauncher}
      $browser = ${lib.getExe pkgs.firefox-beta-bin}
      $editor = ${lib.getExe pkgs.vscode}
      $grim = ${lib.getExe pkgs.grim}
      $slurp = ${lib.getExe pkgs.slurp}
      $wlcopy = ${lib.getExe' pkgs.wl-clipboard "wl-copy"}

      $closeSpecial = ${lib.getExe scripts.closeSpecialWorkspace}

      $mainMod = SUPER
      $altMod = ALT_L

      exec-once = ${pkgs.hyprpaper}/bin/hyprpaper
      exec-once = ${pkgs.swaynotificationcenter}/bin/swaync
      
    '' + (builtins.readFile ./hyprland.conf);
    plugins = [ ];
    systemd = {
      enable = true;
      variables = [ "--all" ];
  };
  xwayland.enable = true;
  };
}
