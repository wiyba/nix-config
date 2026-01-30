let
  more = {
    services = {
      ssh-agent.enable = true;

      gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };
    };
  };
in
[
  more
]