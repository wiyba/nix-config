{ config
, lib
, isServer ? false
, ...
}:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      github-token =
        if isServer then { }
        else { owner = "wiyba"; mode = "0400"; };
      acme-env = { };
      cloudflare = { };
      navidrome-env = { };
      ssh = lib.mkIf (!isServer) {
        owner = "wiyba";
        mode = "0600";
      };
      mail-account-password = lib.mkIf (!isServer) {
        owner = "wiyba";
        mode = "0400";
      };
    };

    templates = lib.mkIf isServer {
      "git-credentials" = {
        owner = "root";
        mode = "0600";
        path = "/root/.git-credentials";
        content = "https://wiyba:${config.sops.placeholder.github-token}@github.com";
      };
    };
  };

  environment.extraInit = ''
    if [ -r /run/secrets/github-token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
    fi
  '';
}
