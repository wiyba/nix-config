{
  pkgs,
  lib,
  inputs,
  ...
}:
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

  packages =
    with pkgs;
    [
      pwvucontrol # pipewire gui
      playerctl # player controller
      sway-audio-idle-inhibit # idle inhibitor
      wl-clipboard # clipboard support
    ]
    ++ fontPkgs;
in
{
  imports = [
    ../../shared
    ../../programs/kitty
    ../../programs/noctalia
  ];

  home = {
    inherit packages;
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      SHELL = "${lib.getExe pkgs.zsh}";
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  fonts.fontconfig.enable = true;

  programs.noctalia-shell.enable = true;

  xdg = {
    desktopEntries.steam = {
      name = "Steam";
      exec = "steam -cef-disable-gpu %U";
      icon = "steam";
      comment = "Application for managing and playing games on Steam";
      categories = [
        "Game"
        "Network"
      ];
      mimeType = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
    };

    configFile = {
      "electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';

      "niri/config.kdl".source = ./config.kdl;
      "niri/config".source = ./config;
    };

    portal = {
      enable = true;
      config = {
        common = {
          default = [
            "gtk"
            "gnome"
          ];
        };
        niri = {
          default = [
            "gtk"
            "gnome"
          ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      xdgOpenUsePortal = true;
    };
  };
}
