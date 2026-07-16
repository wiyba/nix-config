{ config, inputs, lib, pkgs, xrayUsers, xrayHosts, ... }:
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

  sops.secrets = { xray-admin = grp; } // lib.mergeAttrsList (
    map
      (h: {
        "xray-${h}-key-pub" = grp;
        "xray-${h}-sid" = grp;
      })
      xrayHosts
  );

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
