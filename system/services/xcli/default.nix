{ inputs, pkgs, ... }:
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
    xray-relay-key-pub = grp;
    xray-relay-sid = grp;
    xray-moscow-key-pub = grp;
    xray-moscow-sid = grp;
    xray-london-key-pub = grp;
    xray-london-sid = grp;
    xray-stockholm-key-pub = grp;
    xray-stockholm-sid = grp;
    xray-helsinki-key-pub = grp;
    xray-helsinki-sid = grp;
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
