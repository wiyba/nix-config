let
  scripts = { config, lib, pkgs, ... }:
    let
      szp = pkgs.callPackage ./show-zombie-parents.nix { };
      pactl-listner = pkgs.callPackage ./pactl-listner.nix { };
      sync-music = pkgs.callPackage ./sync-music.nix { };
    in
    {
      home.packages = [
        szp
        pactl-listner
        sync-music
      ];
    };
in
[ scripts ]

