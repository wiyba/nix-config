let
  more = {
    services = {
      udisks2.enable = true;
      gvfs.enable = true;
    };
  };
in
[
  ./greetd
  ./pipewire
  ./systemd
  ./mihomo
  more
]
