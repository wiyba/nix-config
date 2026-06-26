final: prev: {
  musicpresence = prev.callPackage ./musicpresence.nix { };
  proxmark3 = prev.callPackage ./proxmark3.nix { inherit (prev) proxmark3; };
  rkn-block-checker = prev.callPackage ./rkn-block-checker.nix { };
  terminal-oscilloscope = prev.callPackage ./terminal-oscilloscope.nix { };
}
