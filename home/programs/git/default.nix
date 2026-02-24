{ pkgs, ... }:
let
  helper = pkgs.writeShellScript "git-credential-readonly" ''
    if [ "$1" = "get" ]; then
      while IFS= read -r line; do
        case "$line" in host=*) host="''${line#host=}" ;; esac
      done
      entry=$(grep -m1 "$host" ~/.git-credentials 2>/dev/null) || exit 1
      echo "$entry" | ${pkgs.gnused}/bin/sed -E 's|https://([^:]+):([^@]+)@(.+)|protocol=https\nhost=\3\nusername=\1\npassword=\2|'
    fi
  '';
in
{
  programs.git = {
    enable = true;

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
