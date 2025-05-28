{ pkgs, lib, ... }:

let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    bottom # alternative to htop & ytop
    dig # dns command-line tool
    duf # disk usage/free utility
    eza # a better "ls"
    fd # "find" for files
    killall # kill processes by name
    libreoffice # office suite
    ncdu # disk space info
    fastfetch # minimal system information fetch
    nix-output-monitor # nom: monitor nix commands
    ranger # terminal file explorer
    screenkey # shows keypresses on screen
    spotify # music player
    tdesktop # telegram messaging client
    tree # display files in a tree view
    vlc # media player
    xsel # clipboard support (also for neovim)
  ];
in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../modules
    ../scripts
    ../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory packages;

    changes-report.enable = true;

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox-beta-bin}";
      DISPLAY = ":0";
      EDITOR = "nvim";
      GIT_ASKPASS = "";
    };
  };

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.user.startServices = "sd-switch";
  news.display = "silent";
}