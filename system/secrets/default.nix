{ config, ... }:
{
  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets.hysteria-auth = { };
    secrets.vless-auth = { };
    secrets.github_token = { };

    secrets.navidrome-env = {
      owner = "navidrome";
    };
    secrets.cloudflare = { };

    secrets.remnawave = {
      path = "/etc/remnawave/.env";
      owner = "root";
      mode = "0600";
    };
    secrets.remnasub = {
      path = "/etc/remnawave/sub.env";
      owner = "root";
      mode = "0600";
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

