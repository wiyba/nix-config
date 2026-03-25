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
      vless-uuid = { };
      reality-key = { };
      xcli-users = { };
      xcli-private-key = { };
      hysteria-secret = { };
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
        "hysteria-config" = {
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
      })
    ];
  };

  environment.extraInit = ''
    if [ -r /run/secrets/github-token ]; then
      export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
    fi
  '';
}
