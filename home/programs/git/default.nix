{ lib, pkgs, ... }:

{
  home.packages = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt # git files encryption
    hub # github command-line client
    tig # diff and commit view
  ];
  
  programs.git = {
    enable = true;
    userName = "wiyba";
    userEmail = "account@wiyba.org";
    extraConfig.core.editor = "nvim";

    aliases = {
      amend = "commit --amend -m";
      br = "branch";
      co = "checkout";
      cob = "checkout -b";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      rmain = "rebase main";
      rc = "rebase --continue";
    };

    extraConfig = {
      init.defaultBranch = "main";
    };

    ignores = [
      ".DS_Store"
    ];
  };
}
