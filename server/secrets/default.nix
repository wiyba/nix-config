{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets.hysteria-users = { };
    secrets."remnanode-${config.networking.hostName}" = { };
    secrets.github_token = { };

    templates.hysteria-config = {
      content = ''
        tls:
          cert: /var/lib/acme/${config.networking.fqdn}/fullchain.pem
          key: /var/lib/acme/${config.networking.fqdn}/key.pem
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
    templates.remnanode-env = {
      content = ''
        SECRET_KEY=${config.sops.placeholder."remnanode-${config.networking.hostName}"}
      '';
      path = "/run/secrets/remnanode.env";
      mode = "0400";
    };
    templates."git-credentials" = {
      owner = "root";
      mode = "0600";
      path = "/root/.git-credentials";
      content = "https://wiyba:${config.sops.placeholder.github_token}@github.com";
    };
  };

  environment.extraInit = ''
    if [ -r /run/secrets/github_token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github_token)"
    fi
  '';
}
