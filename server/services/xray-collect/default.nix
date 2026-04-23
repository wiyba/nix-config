{ pkgs, ... }:
let
  script = pkgs.writeText "xray-collect.py" ''
    import json, os, subprocess, time

    STATE = "/var/lib/xray-agent/usage.json"

    try:
        data = json.load(open(STATE))
    except (FileNotFoundError, ValueError):
        data = {"users": {}}

    out = subprocess.check_output([
        "${pkgs.xray}/bin/xray", "api", "statsquery",
        "--server=127.0.0.1:10085",
        "-pattern=user>>>",
        "-reset",
    ], text=True, timeout=15)

    for s in json.loads(out).get("stat", []):
        name = s.get("name", "")
        value = int(s.get("value", 0))
        parts = name.split(">>>")
        if len(parts) == 4 and parts[0] == "user" and parts[2] == "traffic":
            user = parts[1]
            data["users"][user] = data["users"].get(user, 0) + value

    data["ts"] = int(time.time())

    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f)
    os.replace(tmp, STATE)
  '';
in
{
  systemd.services.xray-collect = {
    description = "xray stats collector";
    after = [ "xray.service" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "xray-agent";
      ExecStart = "${pkgs.python3}/bin/python3 ${script}";
    };
  };

  systemd.timers.xray-collect = {
    description = "xray stats collector tick";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      Unit = "xray-collect.service";
    };
  };
}
