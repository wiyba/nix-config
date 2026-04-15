{ config, lib, isServer ? false, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/sops-age.key";

    secrets = {
      github-token = { };
      acme-env = { };
      cloudflare = { };
      navidrome-env = { };
      vless-user = { };
      vless-admin = { };
      vless-key = { };
      vless-users = { };
      ssh = lib.mkIf (!isServer) {
        owner = "wiyba";
        mode = "0600";
        path = "/home/wiyba/.ssh/ssh.key";
      };
    };

    templates = lib.mkMerge [
      (lib.mkIf (!isServer) {
        "git-creds-wiyba" = {
          owner = "wiyba";
          mode = "0600";
          path = "/home/wiyba/.git-credentials";
          content = "https://wiyba:${config.sops.placeholder.github-token}@github.com";
        };
      })
      (lib.mkIf isServer {
        "git-credentials" = {
          owner = "root";
          mode = "0600";
          path = "/root/.git-credentials";
          content = "https://wiyba:${config.sops.placeholder.github-token}@github.com";
        };
      })
    ];
  };

  environment.extraInit = ''
    if [ -r /run/secrets/github-token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
    fi
  '';
}
