{ pkgs, ... }:
let
  helper = pkgs.writeShellScript "git-credential-github" ''
    if [ "$1" = "get" ] && [ -r /run/secrets/github-token ]; then
      printf 'username=wiyba\npassword=%s\n' "$(cat /run/secrets/github-token)"
    fi
  '';
in
{
  programs.git = {
    enable = true;
    signing.format = null;

    settings = {
      user = {
        name = "wiyba";
        email = "account@wiyba.org";
      };

      credential."https://github.com".helper = "${helper}";

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
