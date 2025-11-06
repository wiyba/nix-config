let
  scripts = { config, lib, pkgs, ... }:
    let
      csw = pkgs.callPackage ./close-special-workspace.nix { };
      kls = pkgs.callPackage ./keyboard-layout-switch.nix { };
      szp = pkgs.callPackage ./show-zombie-parents.nix { };
    in
    {
      home.packages = [
        csw
        kls
        szp
      ];
    };
in
scripts

