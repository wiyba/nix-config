{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    diff-so-fancy
    git-crypt
    hub
    tig
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "wiyba";
        email = "account@wiyba.org";
      };

      credential."https://github.com".helper = "!gh auth git-credential";

      core.editor = "nvim";
      init.defaultBranch = "main";

      alias = {
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
    };

    ignores = [
      ".DS_Store"
    ];
  };
}
