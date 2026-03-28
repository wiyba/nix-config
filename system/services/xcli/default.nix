{ inputs, ... }:
{
  systemd.services.xcli = {
    description = "xcli";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${inputs.xcli.packages.x86_64-linux.default}/bin/xcli";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
