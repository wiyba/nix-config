{ pkgs, lib, config, ... }:
let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";
  
  packages = with pkgs; [
    dig
    btop
    duf
    eza
    fd
    killall
    xsel
  ];
in
{
  imports = [
    ./plasma.nix
    ./hyprland.nix
  ] ++ lib.concatMap import [
    ./scripts
    ./programs
    ./services
    ./sops
    ./themes
  ];

  programs.home-manager.enable = true;
  
  # important!!!
  plasma.enable = false;
  hyprland.enable = true;

  xdg = {
    inherit configHome;
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${homeDirectory}/Desktop";
      documents = "${homeDirectory}/Documents";
      download = "${homeDirectory}/Downloads";
      music = "${homeDirectory}/Music";
      pictures = "${homeDirectory}/Pictures";
      videos = "${homeDirectory}/Videos";

      publicShare = homeDirectory;
      templates = homeDirectory;
    };
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      
      config = lib.mkMerge [
        (lib.mkIf config.plasma.enable {
          kde.default = [ "kde" "gtk" "gnome" ];
          kde."org.freedesktop.portal.FileChooser" = [ "kde" ];
          kde."org.freedesktop.portal.OpenURI" = [ "kde" ];
        })
        
        (lib.mkIf config.hyprland.enable {
          hyprland.default = [ "hyprland" "gtk" "gnome" "termfilechooser" ];
          hyprland."org.freedesktop.portal.FileChooser" = [ "termfilechooser" ];
          hyprland."org.freedesktop.portal.OpenURI" = [ "termfilechooser" ];
        })
      ];
      
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ] ++ lib.optionals config.plasma.enable [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ] ++ lib.optionals config.hyprland.enable [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    };
  };

  home = {
    inherit username homeDirectory packages;
    stateVersion = "24.11";
    sessionVariables = {
      DISPLAY = ":0";
      BROWSER = "${lib.getExe pkgs.firefox-beta}";
      SHELL = "${lib.getExe pkgs.zsh}";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_ASKPASS = "";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.user.startServices = "sd-switch";
  news.display = "silent";
}