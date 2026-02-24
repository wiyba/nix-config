{ pkgs, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "wiyba";
    repo = "hyst-panel";
    rev = "0ddf61eb7e49510bb47e01b59d62a31979db7fc2";
    sha256 = "19lp0rsinay3fhzy2z5l81253pzybdxqla2hbrbl4whzbcgjgb6a";
  };

  env = pkgs.python3.withPackages (ps: with ps; [
    fastapi uvicorn httpx jinja2
  ]);

  cli = pkgs.writeShellScriptBin "hyst-panel" ''
    export HYST_DB_PATH="/var/lib/hyst-panel/app.db"
    exec ${env}/bin/python ${src}/main.py "$@"
  '';
in
{
  users.groups.hysteria = {};
  users.users.hysteria = {
    isSystemUser = true;
    group = "hysteria";
    home = "/var/lib/hyst-panel";
  };

  environment.systemPackages = [ cli ];

  systemd.services.hyst-panel-setup = {
    description = "Import hyst-panel users";
    wantedBy = [ "multi-user.target" ];
    before = [ "hyst-panel.service" ];
    after = [ "sops-nix.service" ];
    requiredBy = [ "hyst-panel.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "hysteria";
      Group = "hysteria";
      StateDirectory = "hyst-panel";
      StateDirectoryMode = "0770";
    };

    environment.HYST_DB_PATH = "/var/lib/hyst-panel/app.db";

    script = ''
      ${env}/bin/python ${src}/main.py import /run/secrets/hysteria-users
    '';
  };

  systemd.services.hyst-panel = {
    description = "Hysteria auth panel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "hyst-panel-setup.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "hysteria";
      Group = "hysteria";
      StateDirectory = "hyst-panel";
      StateDirectoryMode = "0770";
      WorkingDirectory = src;
      ExecStart = "${env}/bin/python ${src}/main.py run";
      Restart = "on-failure";
      RestartSec = 5;
    };

    environment.HYST_DB_PATH = "/var/lib/hyst-panel/app.db";
  };
}
