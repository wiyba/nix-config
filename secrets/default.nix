{ config, lib, isServer ? false, ... }:
let
  usernames = import ./users.nix;
  xrayHosts = [ "relay" "london" ];

  uuidSecrets = lib.listToAttrs (map (u: {
    name = "xray-uuid-${u}";
    value = { key = "xray/uuids/${u}"; };
  }) usernames);

  hostSecrets = lib.listToAttrs (lib.concatMap (h: [
    { name = "xray-${h}-key-priv";   value = { key = "xray/${h}/key_priv"; }; }
    { name = "xray-${h}-key-pub";    value = { key = "xray/${h}/key_pub"; }; }
    { name = "xray-${h}-sid";        value = { key = "xray/${h}/sid"; }; }
    { name = "xray-${h}-xhttp-path"; value = { key = "xray/${h}/xhttp_path"; }; }
  ]) xrayHosts);
in
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/sops-age.key";

    secrets = uuidSecrets // hostSecrets // {
      github-token = { };
      acme-env = { };
      cloudflare = { };
      navidrome-env = { };
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
        xcli-users = {
          owner = "root";
          mode = "0444";
          path = "/run/secrets/xcli-users.json";
          content = builtins.toJSON (lib.listToAttrs (map (u: {
            name = u;
            value = config.sops.placeholder."xray-uuid-${u}";
          }) usernames));
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
