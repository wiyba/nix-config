{ config, lib, host, ... }:
{
  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/sops-age.key";

    secrets.hysteria-auth = { };
    secrets.vless-auth = { };
    secrets.github_token = { };

    secrets.navidrome-env = lib.mkIf (host == "home") {
      owner = "navidrome";
    };
    secrets.acme-env = lib.mkIf (host == "home") {
      owner = "acme";
    };

    secrets.multi = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.ssh/multi.key";
    };
    templates."git-credentials" = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };
  };
}
