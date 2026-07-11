{ config, inputs, pkgs, xrayUsers, ... }:
let
  xcli = inputs.xcli.packages.${pkgs.stdenv.hostPlatform.system}.default;
  grp = {
    group = "xcli";
    mode = "0440";
  };
in
{
  users.users.xcli = {
    isSystemUser = true;
    group = "xcli";
  };
  users.groups.xcli = { };
  users.users.wiyba.extraGroups = [ "xcli" ];

  sops.secrets = {
    xray-admin = grp;
    xray-stockholm-key-pub = grp;
    xray-stockholm-sid = grp;
    xray-helsinki-key-pub = grp;
    xray-helsinki-sid = grp;
    xray-home-key-pub = grp;
    xray-home-sid = grp;
  };

  sops.templates.xray-users = {
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
        xrayUsers
    );
  };

  environment.systemPackages = [ xcli ];

  systemd.services.xcli = {
    description = "xcli";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${xcli}/bin/xcli run";
      User = "xcli";
      Group = "xcli";
      UMask = "0002";
      StateDirectory = "xcli";
      StateDirectoryMode = "0770";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
