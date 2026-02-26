{ inputs }:

let
  pkgs-navidrome = import inputs.nixpkgs-navidrome {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
final: prev: {
  musicpresence = prev.callPackage ./musicpresence.nix { };
  navidrome = pkgs-navidrome.navidrome;
}
