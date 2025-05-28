let
  more = {
    services = {
      gnome-keyring = {
        enable = true;
        components = [ "ssh" "secrets" ];
      };
    };
  };
in
[
  ../services/hypridle
  more
]