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
    btop
  ];
in
{
  imports = lib.concatMap import [ ./programs ];

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

  news.display = "silent";
}
