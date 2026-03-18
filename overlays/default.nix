final: prev: {
  musicpresence = prev.callPackage ./musicpresence.nix { };
  proxmark3 = prev.callPackage ./proxmark3.nix { inherit (prev) proxmark3; };
}
