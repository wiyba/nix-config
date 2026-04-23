{ inputs, pkgs, ... }:
let
  xcli = inputs.xcli.packages.${pkgs.system}.default;
in
{
  environment.systemPackages = [ xcli ];

  systemd.services.xcli = {
    description = "xcli";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${xcli}/bin/xcli serve";
      StateDirectory = "xcli";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.services.xcli-collect = {
    description = "xcli collect";
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "xcli";
      ExecStart = "${xcli}/bin/xcli collect";
    };
  };

  systemd.timers.xcli-collect = {
    description = "xcli collect tick";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "10min";
      Unit = "xcli-collect.service";
    };
  };
}
