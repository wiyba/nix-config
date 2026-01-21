{
  pkgs,
  lib,
  ...
}:
let
  packages = with pkgs; [
    dig
    btop
    duf
    eza
    fd
    killall
    age
    sops
    unzip
    zip
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
    jq
    htop
    btop
  ];
in
{
  imports = lib.concatMap import [ ./programs ];

  programs.home-manager.enable = true;
  xdg.enable = true;
  home = {
    inherit packages;
    username = "root";
    homeDirectory = "/root";
    stateVersion = "24.11";
    sessionVariables = {
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

  targets.genericLinux.enable = true;
  news.display = "silent";
}
