let
  scripts = { config, lib, pkgs, ... }:
    let
      pactl-listner = pkgs.callPackage ./pactl-listner.nix { };
      sync-music = pkgs.callPackage ./sync-music.nix { };
      close-special-workspace = pkgs.callPackage ./close-special-workspace.nix { };
      get-weather = pkgs.callPackage ./get-weather.nix { };
      bitwarden-handler = pkgs.callPackage ./bitwarden-handler.nix { };
    in
    {
      home.packages = [
        pactl-listner
        sync-music
        close-special-workspace
        get-weather
        bitwarden-handler
      ];
    };
in
[ scripts ]

