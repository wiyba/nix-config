{
  pkgs,
  lib,
  ...
}:
let
  username = "root";
  homeDirectory = "/root";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    dig
    btop
    duf
    eza
    fd
    killall
    xsel
    age
    sops
    unzip
    zip
    wl-clipboard
    socat
    statix
    ruff
    nil
    direnv
    packwiz
    mtr
    nodejs
    pnpm
    claude-code
    file
    openssl
  ];
in
{
  imports = lib.concatMap import [
    ./programs
    ./sops
  ];

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  xdg = {
    inherit configHome;
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = false;

      desktop = "${homeDirectory}/Desktop";
      documents = "${homeDirectory}/Documents";
      download = "${homeDirectory}/Downloads";
      music = "${homeDirectory}/Music";
      pictures = "${homeDirectory}/Pictures";
      videos = "${homeDirectory}/Videos";

      publicShare = homeDirectory;
      templates = homeDirectory;
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
