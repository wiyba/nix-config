{ config
, lib
, isServer ? false
, ...
}:
let
  users = [
    { name = "cvaze"; admin = false; }
    { name = "irs"; admin = false; }
    { name = "kika"; admin = false; }
    { name = "osman"; admin = false; }
    { name = "obguy"; admin = false; }
    { name = "helsinki"; admin = false; }
    { name = "stockholm"; admin = false; }
    { name = "wiyba"; admin = true; }
    { name = "home"; admin = true; }
    { name = "mamo"; admin = true; }
    { name = "papo"; admin = true; }
    { name = "nonplay"; admin = true; }
  ];

  userSecrets = lib.listToAttrs (
    map
      (user: {
        name = "xray-uuid-${user.name}";
        value.key = "xray/${if user.admin then "admins" else "users"}/${user.name}";
      })
      users
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
        "stockholm"
        "helsinki"
        "home"
        "almaty"
      ]
  );
in
{
  _module.args.xrayUsers = users;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets =
      userSecrets
      // hostSecrets
      // {
        github-token =
          if isServer then { }
          else { owner = "wiyba"; mode = "0400"; };
        acme-env = { };
        cloudflare = { };
        navidrome-env = { };
        xray-admin = { };
        ssh = lib.mkIf (!isServer) {
          owner = "wiyba";
          mode = "0600";
        };
        mail-account-password = lib.mkIf (!isServer) {
          owner = "wiyba";
          mode = "0400";
        };
      };

    templates = lib.mkMerge [
      (lib.mkIf (!isServer) {
        xray-users = {
          owner = "root";
          mode = "0444";
          path = "/run/secrets/xray-users.json";
          content = builtins.toJSON (
            map
              (user: {
                user = user.name;
                uuid = config.sops.placeholder."xray-uuid-${user.name}";
                inherit (user) admin;
              })
              users
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
