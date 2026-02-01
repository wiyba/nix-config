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

    secrets.mihomo = {
      mode = "0400";
      path = "/etc/mihomo/config.yaml";
    };
    secrets.multi = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.ssh/multi.key";
    };
    secrets.github_token = { };

    templates."git-credentials" = {
      owner = "wiyba";
      mode = "0600";
      path = "/home/wiyba/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };
  };
}
