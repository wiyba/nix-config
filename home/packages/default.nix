[
  ({ pkgs, lib, ... }:
  let
    files = builtins.filter (n: n != "default.nix" && lib.hasSuffix ".nix" n)
      (builtins.attrNames (builtins.readDir ./.));
  in {
    home.packages = lib.concatMap (f: pkgs.callPackage (./. + "/${f}") { }) files;
  })
]
