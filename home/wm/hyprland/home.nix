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

  audioPkgs = with pkgs; [
    pasystray
    pavucontrol
    playerctl
    pulsemixer
  ];

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
    papirus-icon-theme
    quickshell
    qt6.qtwayland
    qt6.qtpositioning
    qt6.qtsvg
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qt5compat    
    grim 
    slurp 
    wl-clipboard 
    cliphist 
    imagemagick 
    jq
    swww
    brightnessctl
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
      monitor = eDP-1, 2880x1800@60.00Hz, auto, 1.25, vrr, 1
      monitor = HDMI-A-1, preferred, auto, 1.0, mirror, eDP-1

      debug:overlay = 0
      misc:vrr = 1
      misc:vfr = false 
      
      $terminal = ${lib.getExe pkgs.kitty}
      $fileManager = ${lib.getExe pkgs.nemo}
      $browser = ${lib.getExe pkgs.firefox-beta}
      $editor = ${lib.getExe pkgs.vscode}
      $grim = ${lib.getExe pkgs.grim}
      $slurp = ${lib.getExe pkgs.slurp}
      $wlcopy = ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
      $lock = ${lib.getExe pkgs.hyprlock}

      $closeSpecial = ${lib.getExe scripts.closeSpecialWorkspace}

      $mainMod = SUPER
      $altMod = ALT_L

      exec-once = ${pkgs.hyprpaper}/bin/hyprpaper
      exec-once = ${pkgs.blueman}/bin/blueman-applet
      exec-once = ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
      exec-once = ${pkgs.pasystray}/bin/pasystray
      exec-once = ${pkgs.hyprlock}/bin/hyprlock

      # exec-once = ${pkgs.nekoray}/bin/nekoray -tray -appdata
      exec-once = sleep 2 && ${pkgs.clash-verge-rev}/bin/clash-verge
      '' + (builtins.readFile ./hyprland.conf);
   # exec-once = sleep 5 && sudo ${inputs.clash-verge.legacyPackages.${pkgs.system}.clash-verge-rev}/bin/clash-verge-service
   # exec-once = sleep 8 && ${inputs.clash-verge.legacyPackages.${pkgs.system}.clash-verge-rev}/bin/clash-verge
    plugins = [ ];
    systemd = {
      enable = true;
      variables = [ "--all" ];
  };
  xwayland.enable = true;
  };
}
