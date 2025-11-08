let
  scripts = { config, lib, pkgs, ... }:
    let
      pactl-listner = pkgs.callPackage ./pactl-listner.nix { };
      sync-music = pkgs.callPackage ./sync-music.nix { };
    in
    {
      home.packages = [
        pactl-listner
        sync-music
      ];
    };
in
[ scripts ]

