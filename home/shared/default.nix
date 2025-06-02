{ pkgs, lib, inputs, ... }:

let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    dig # dns command-line tool
    btop # htop but better
    duf # disk usage/free utility
    eza # a better "ls"
    fd # "find" for files
    killall # kill processes by name
    libreoffice # office suite
    ncdu # disk space info
    fastfetch # minimal system information fetch
    spotify # music player
    tdesktop # telegram messaging client
    vlc # media player
    xsel # clipboard support (also for neovim)
    inputs.zen-browser.packages.${pkgs.system}.default # zen-browser (firefox but better)
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

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox-beta-bin}";
      DISPLAY = ":0";
      EDITOR = "nvim";
      VISUAL = "nvim";
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
