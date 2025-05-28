{ pkgs, lib, ... }:

let
  nerdFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    caskaydia-cove
    iosevka
  ];

  fontPkgs = with pkgs; [
    font-awesome
    material-design-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ] ++ nerdFonts;

  audioPkgs = with pkgs; [
    paprefs
    pasystray
    pavucontrol
    playerctl
    pulsemixer
    reaper
  ];

  packages = with pkgs; [
    loupe
    swaync
    nemo
    nix-search
    unzip
    grim
    slurp
    wl-clipboard
    wofi
    zip
    kdePackages.xwaylandvideobridge
  ] ++ fontPkgs ++ audioPkgs;

  scripts = pkgs.callPackage ./scripts.nix { };

in
{
  imports = [
    ../../shared
    ../../programs/kitty
    ../../programs/hyprlock
    ../../programs/hyprpaper
    ../../programs/waybar
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
      $menu = ${lib.getExe pkgs.wofi}
      $browser = ${lib.getExe pkgs.firefox-beta-bin}
      $editor = ${lib.getExe pkgs.vscode}
      $grim = ${lib.getExe pkgs.grim}
      $slurp = ${lib.getExe pkgs.slurp}
      $wlcopy = ${lib.getExe pkgs.wl-clipboard}

      $closeSpecial = ${lib.getExe scripts.closeSpecialWorkspace}

      $mainMod = SUPER
      $altMod = ALT_L
    '' + (builtins.readFile ./hyprland.conf);
  plugins = [ ];
  systemd = {
    enable = true;
    variables = [ "--all" ];
  };
  xwayland.enable = true;
};
}