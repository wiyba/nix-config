let
  more =
    { pkgs, ... }:
    {
      services = {
        ssh-agent.enable = true;

        gnome-keyring = {
          enable = true;
          components = [ "secrets" ];
        };

        blueman-applet.enable = false;
      };

      systemd.user.services.hyprpolkitagent = {
        Unit.Description = "hyprland gui polkit";
        Unit.After = [ "graphical-session.target" ];
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Restart = "on-failure";
        };
      };
    };
in
[
  more
]
