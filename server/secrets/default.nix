{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets.hysteria-users = { };
    secrets.hysteria-secret = { };
    secrets.github_token = { };

    templates.hysteria-config = {
      content = ''
        tls:
          cert: /var/lib/acme/${config.networking.fqdn}/fullchain.pem
          key: /var/lib/acme/${config.networking.fqdn}/key.pem
        trafficStats:
          listen: 127.0.0.1:9999
          secret: ${config.sops.placeholder.hysteria-secret}
        auth:
          type: http
          http:
            url: https://hyst.wiyba.org/auth
        acl:
          inline:
            - reject(127.0.0.0/8)
            - reject(10.0.0.0/8)
            - reject(172.16.0.0/12)
            - reject(192.168.0.0/16)
        masquerade:
          type: proxy
          proxy:
            url: https://status.wiyba.org/
            rewriteHost: true
      '';
      path = "/etc/hysteria/config.yaml";
      mode = "0444";
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
