{
  config,
  lib,
  isServer ? false,
  ...
}:
let
  yamlLines = lib.splitString "\n" (builtins.readFile ./secrets.yaml);

  parseStep =
    state: line:
    if builtins.match "    users:.*" line != null then
      state // { section = "user"; }
    else if builtins.match "    admins:.*" line != null then
      state // { section = "admin"; }
    else if state.section != null && builtins.match "^([^ ]|    [^ ]).*" line != null then
      state // { section = null; }
    else if state.section == null then
      state
    else
      let
        nameMatch = builtins.match "^        ([a-zA-Z0-9_-]+):.*" line;
      in
      if nameMatch == null then
        state
      else
        state
        // {
          entries = state.entries ++ [
            {
              name = builtins.head nameMatch;
              admin = state.section == "admin";
            }
          ];
        };

  users =
    (lib.foldl' parseStep {
      section = null;
      entries = [ ];
    } yamlLines).entries;

  userSecrets = lib.listToAttrs (
    map (user: {
      name = "xray-uuid-${user.name}";
      value.key = "xray/${if user.admin then "admins" else "users"}/${user.name}";
    }) users
  );

  hostSecrets = lib.listToAttrs (
    lib.concatMap
      (
        host:
        map
          (key: {
            name = "xray-${host}-${lib.replaceStrings [ "_" ] [ "-" ] key}";
            value.key = "xray/${host}/${key}";
          })
          [
            "key_priv"
            "key_pub"
            "sid"
          ]
      )
      [
        "relay"
        "london"
        "stockholm"
      ]
  );
in
{
  _module.args.xrayUsers = users;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/sops-age.key";

    secrets =
      userSecrets
      // hostSecrets
      // {
        github-token = { };
        acme-env = { };
        cloudflare = { };
        navidrome-env = { };
        xray-admin = { };
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
        xray-users = {
          owner = "root";
          mode = "0444";
          path = "/run/secrets/xray-users.json";
          content = builtins.toJSON (
            map (user: {
              user = user.name;
              uuid = config.sops.placeholder."xray-uuid-${user.name}";
              inherit (user) admin;
            }) users
          );
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
