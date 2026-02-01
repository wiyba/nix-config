{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets.hysteria-users = {
      owner = "root";
      mode = "0400";
    };
    templates.hysteria-config = {
      content = ''
        acme:
          domains:
            - ${config.networking.fqdn}
          email: admin@wiyba.org
        trafficStats:
          listen: 127.0.0.1:9999
        auth:
          type: userpass
          userpass: 
            ${config.sops.placeholder.hysteria-users}
        masquerade:
          type: proxy
          proxy:
            url: https://excalidraw.com/
            rewriteHost: true
      '';
      path = "/etc/hysteria/config.yaml";
      mode = "0444";
    };
    secrets."remnanode-${config.networking.hostName}" = {
      owner = "root";
      mode = "0400";
    };
    templates.remnanode-env = {
      content = ''
        SECRET_KEY=${config.sops.placeholder."remnanode-${config.networking.hostName}"}
      '';
      path = "/run/secrets/remnanode.env";
      mode = "0400";
    };

    secrets.github_token = { };

    templates."git-credentials" = {
      owner = "root";
      mode = "0600";
      path = "/root/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };

    secrets.multi = {
      owner = "root";
      mode = "0600";
      path = "/root/.ssh/multi.key";
    };
  };

  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';
}
