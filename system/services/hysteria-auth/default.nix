{ pkgs, ... }:
let
  env = pkgs.python3.withPackages (ps: with ps; [
    fastapi uvicorn httpx jinja2 pydantic requests annotated-types
    anyio certifi charset-normalizer click h11 httpcore idna
    markupsafe starlette typing-extensions
  ]);
  cli = pkgs.writeShellScriptBin "hyst-panel" ''
    exec ${env}/bin/python /home/wiyba/Projects/hyst-panel/main.py "$@"
  '';
in
{
  environment.systemPackages = [ env cli ];
  systemd.services.hyst-panel-setup = {
    description = "setup hyst-panel";
    wantedBy = [ "multi-user.target" ];
    before = [ "hyst-panel.service" ];
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    requiredBy = [ "hyst-panel.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    script = ''
      if [ ! -d "/home/wiyba/Projects/hyst-panel/.git" ]; then
        ${pkgs.git}/bin/git clone https://github.com/wiyba/hyst-panel.git /home/wiyba/Projects/hyst-panel
      else
        cd /home/wiyba/Projects/hyst-panel
        ${pkgs.git}/bin/git pull
      fi
      cd /home/wiyba/Projects/hyst-panel
      ${env}/bin/python main.py import /run/secrets/hysteria-users
      chown -R wiyba:users /home/wiyba/Projects/hyst-panel
    '';
  };

  systemd.services.hyst-panel = {
    description = "hyst-panel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "hyst-panel-setup.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "wiyba";
      WorkingDirectory = "/home/wiyba/Projects/hyst-panel";
      ExecStart = "${env}/bin/python main.py run";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}