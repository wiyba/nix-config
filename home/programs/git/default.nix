{ lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "wiyba";
    userEmail = "account@wiyba.org";
    extraConfig.core.editor = "nvim";

    aliases = {
      st = "status";
      ci = "commit";
    };

    extraConfig = {
      init.defaultBranch = "main";
    };

    ignores = [
      ".DS_Store"
    ];
  };
}
