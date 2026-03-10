{ pkgs, ... }:

let
  steamcmd = "${pkgs.steamcmd}/bin/steamcmd";
  steam-run = "${pkgs.steam-run}/bin/steam-run";
  installDir = "/var/lib/satisfactory/server";
in
{
  networking.firewall.allowedUDPPorts = [ 7777 ];
  networking.firewall.allowedTCPPorts = [ 7777 8888 ];

  users.users.satisfactory = {
    isSystemUser = true;
    group = "satisfactory";
    home = "/var/lib/satisfactory";
    createHome = true;
  };
  users.groups.satisfactory = {};

  systemd.services.satisfactory-server = {
    description = "Satisfactory Dedicated Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "satisfactory";
      Group = "satisfactory";
      StateDirectory = "satisfactory";
      WorkingDirectory = "/var/lib/satisfactory";

      ExecStartPre = "${steamcmd} +@sSteamCmdForcePlatformType linux +force_install_dir ${installDir} +login anonymous +app_update 1690800 validate +quit";
      ExecStart = "${steam-run} ${installDir}/FactoryServer.sh -unattended -multihome=0.0.0.0";

      Restart = "on-failure";
      RestartSec = 30;

      TimeoutStartSec = "infinity";
    };
  };
}
