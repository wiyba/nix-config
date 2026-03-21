{ inputs, config, ... }:
let
  xcli = inputs.xcli.packages.x86_64-linux.default;
in
{
  environment.systemPackages = [ xcli ];

  systemd.services.xcli = {
    description = "xcli subscription server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };

    script = ''
      exec ${xcli}/bin/xcli run
    '';

    environment = {
      XCLI_USERS_FILE = config.sops.secrets.xcli-users.path;
      XCLI_HOSTS_FILE = config.sops.secrets.xcli-hosts.path;
      XCLI_PUBLIC_KEY = "u-2Rr_En_Jx0agQKMG7DlwlLPus2hPLBPMXlOM_-lVU";
      XCLI_SHORT_ID = "4ba9b78acaa91b44";
      XCLI_SNI = "yandex.ru";
    };
  };
}
