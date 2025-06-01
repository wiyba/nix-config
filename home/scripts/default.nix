let
  scripts = { config, lib, pkgs, ... }:
    let
      gsk = pkgs.callPackage ./gen-ssh-key.nix { };
      kls = pkgs.callPackage ./keyboard-layout-switch.nix { };
      szp = pkgs.callPackage ./show-zombie-parents.nix { };
    in
    {
      home.packages = [
        gsk
        kls
        szp
      ];
    };
in
[ scripts ]