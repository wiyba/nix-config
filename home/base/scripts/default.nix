let
  scripts = { config, lib, pkgs, ... }:
    let
      szp = pkgs.callPackage ./show-zombie-parents.nix { };
      pactl-listner = pkgs.callPackage ./pactl-listner.nix { };
    in
    {
      home.packages = [
        szp
        pactl-listner
      ];
    };
in
[ scripts ]

