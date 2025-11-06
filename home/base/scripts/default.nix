let
  scripts = { config, lib, pkgs, ... }:
    let
      szp = pkgs.callPackage ./show-zombie-parents.nix { };
    in
    {
      home.packages = [
        szp
      ];
    };
in
[ scripts ]

