let
  scripts = { config, lib, pkgs, ... }:
    let
      close-special-workspace = pkgs.callPackage ./close-special-workspace.nix { };
      get-weather = pkgs.callPackage ./get-weather.nix { };
      bitwarden-handler = pkgs.callPackage ./bitwarden-handler.nix { };
    in
    {
      home.packages = [
        close-special-workspace
        get-weather
        bitwarden-handler
      ];
    };
in
[ scripts ]
