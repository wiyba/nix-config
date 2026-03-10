{ inputs, ... }:
let
  hyst-panel = inputs.hyst-panel.packages.x86_64-linux.default;
in
{
  users.groups.hysteria = {};
  users.users.hysteria = {
    isSystemUser = true;
    group = "hysteria";
    home = "/var/lib/hyst-panel";
  };

  environment.systemPackages = [ hyst-panel ];

  systemd.services.hyst-panel = {
    description = "hyst-panel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "hysteria";
      Group = "hysteria";
      StateDirectory = "hyst-panel";
      StateDirectoryMode = "0770";
      UMask = "0007";
      ExecStart = "${hyst-panel}/bin/hyst-panel run";
      Restart = "on-failure";
      RestartSec = 5;
    };

    environment.HYST_DB_PATH = "/var/lib/hyst-panel/app.db";
  };
}
