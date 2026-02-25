{ pkgs, lib, host, ... }:
let
  nerdFonts = with pkgs.nerd-fonts; [
    symbols-only
    caskaydia-cove
  ];

  fontPkgs =
    with pkgs;
    [
      font-awesome
      material-design-icons
      noto-fonts
      noto-fonts-cjk-sans # chinese and japanese languages
      noto-fonts-color-emoji # emojis
    ]
    ++ nerdFonts;

  packages = with pkgs; [
    grim # screenshots
    grimblast # screenshot program from hyprland
    hypridle # idle daemon for hyprland
    hyprlock # lockscreen for hyprland
    hyprpaper # wallpaper daemon for hyprland
    pavucontrol # pulseaudio gui
    playerctl # player controller
    swaynotificationcenter # notifications daemon
    sway-audio-idle-inhibit # idle inhibitor
    wl-clipboard # clipboard support
    wofi # app launcher
  ] ++ fontPkgs;
in
{
  imports = [
    ../../shared
    ../../programs/kitty
    ../../programs/waybar
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

  systemd.user.startServices = lib.mkForce "suggest";

  xdg = {
    configFile = {
      "electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';

      "hypr/hyprlock.conf".text = (builtins.readFile ./hyprlock.conf);
      "hypr/hyprpaper.conf".text = (builtins.readFile ./hyprpaper.conf);
      "hypr/hypridle.conf".text = (builtins.readFile ./hypridle.conf);
    };

    portal = {
      enable = true;
      config = {
        common = {
          default = [ "hyprland" "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      xdgOpenUsePortal = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = (builtins.readFile ./hyprland.conf);
    plugins = [ ];
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    xwayland.enable = true;
  };
}
