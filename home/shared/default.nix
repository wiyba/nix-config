{ config, pkgs, lib, inputs, ... }:

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
    tdesktop # telegram messaging client
    vesktop # discord but better
    vlc # media player
    xsel # clipboard support (also for neovim)
  ];
in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../scripts
    ../themes
    ./programs.nix
    ./services.nix
  ] ++ [ ../../secrets ];
  
  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory packages;

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox-beta}";
      DISPLAY = ":0";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_ASKPASS = "";
      SOPS_AGE_KEY_FILE = "/etc/nixos/secrets/keys/sops-age.key";
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
