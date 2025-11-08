let
  more = { config, pkgs, ... }:
  {
    services = {

    };
  };
in
[
  ./mpd
] ++ [ more ]
