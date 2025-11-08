{ lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
}
