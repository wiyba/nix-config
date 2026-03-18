{ pkgs, inputs, config, ... }:
let
  xcli = inputs.xcli.packages.x86_64-linux.default;
in
{
  systemd.services.xray = {
    description = "xray server";
    after = [ "network.target" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      RuntimeDirectory = "xray";
      Restart = "always";
      RestartSec = 5;
    };

    environment = {
      XCLI_USERS_FILE = config.sops.secrets.xcli-users.path;
      XCLI_PRIVATE_KEY_FILE = "unused";
    };

    script = ''
      export XCLI_PRIVATE_KEY="$(cat ${config.sops.secrets.xcli-private-key.path})"
      ${xcli}/bin/xcli generate config > /run/xray/config.json
      exec ${pkgs.xray}/bin/xray run -c /run/xray/config.json
    '';
  };
}
