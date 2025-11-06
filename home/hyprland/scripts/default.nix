let
  scripts = { config, lib, pkgs, ... }:
    let
      csw = pkgs.callPackage ./close-special-workspace.nix { };
      kls = pkgs.callPackage ./keyboard-layout-switch.nix { };
    in
    {
      home.packages = [
        csw
        kls
      ];
    };
in
[ scripts ]

