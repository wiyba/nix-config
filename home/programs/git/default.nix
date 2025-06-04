{ lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "wiyba";
    userEmail = "account@wiyba.org";
    extraConfig.core.editor = "nvim";

    home.packages = with pkgs.gitAndTools; [
	    diff-so-fancy # git diff with colors
	    git-crypt # git files encryption
	    hub # github command-line client
	    tig # diff and commit view
	  ];

    aliases = {
      amend = "commit --amend -m";
      fixup = "!f(){ git reset --soft HEAD~\${1} && git commit --amend -C HEAD; };f";
      loc = "!f(){ git ls-files | ${rg} \"\\.\${1}\" | xargs wc -l; };f"; # lines of code
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
