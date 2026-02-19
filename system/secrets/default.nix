{ config, lib, host, ... }:
{
  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/system/secrets/sops-age.key";

    secrets.hysteria-auth = { };
    secrets.hysteria-users = { };
    secrets.github_token = { };

    secrets.navidrome-env = lib.mkIf (host == "home") {
      owner = "navidrome";
    };
    secrets.acme-env = lib.mkIf (host == "home") {
      owner = "acme";
    };

    secrets.ssh = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.ssh/ssh.key";
    };

    templates."git-creds-wiyba" = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };

    templates."git-creds-root" = {
      owner = "root";
      mode = "0600";
      path = "/root/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };
  };
}
