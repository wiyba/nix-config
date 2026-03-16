{ config, ... }:
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
    secrets.vless-uuid = { };
    secrets.reality-key = { };
    secrets.github_token = { };

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
  };
}
