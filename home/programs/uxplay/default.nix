{ pkgs
, ...
}:
{
  home.packages = [ pkgs.uxplay ];

  systemd.user.services.uxplay = {
    Unit = {
      Description = "airplay reciver";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.uxplay}/bin/uxplay";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
