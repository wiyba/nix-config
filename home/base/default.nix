{ config, pkgs, lib, inputs, ... }:

let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    polkit_gnome # gnome polkit
    dig # dns command-line tool
    btop # htop but better
    duf # disk usage/free utility
    eza # a better "ls"
    fd # "find" for files
    killall # kill processes by name
    xsel # clipboard support (also for neovim)
  ];
in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ./scripts
    ./programs
    ./services
    ./secrets
  ];

  systemd.user.services.polkit-agent = {
    Unit = { Description = "PolicyKit Authentication Agent"; };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
  
  xdg = {
    inherit configHome;
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      pictures = "${homeDirectory}/Pictures";
    };
  };

  home = {
    inherit username homeDirectory packages;
    stateVersion = "24.11";

    sessionVariables = {
      DISPLAY = ":0";
      SHELL = "${lib.getExe pkgs.zsh}";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_ASKPASS = "";
      SOPS_AGE_KEY_FILE = "/etc/nixos/home/secrets/keys/sops-age.key";
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
