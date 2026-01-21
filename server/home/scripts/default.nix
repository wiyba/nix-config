let
  scripts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      pactl-listner = pkgs.callPackage ./pactl-listner.nix { };
      sync-music = pkgs.callPackage ./sync-music.nix { };
      close-special-workspace = pkgs.callPackage ./close-special-workspace.nix { };
      get-weather = pkgs.callPackage ./get-weather.nix { };
      bitwarden-handler = pkgs.callPackage ./bitwarden-handler.nix { };
      proxy-status = pkgs.callPackage ./proxy-status.nix { };
      proxy-switch = pkgs.callPackage ./proxy-switch.nix { };
      proxy-profile-switch = pkgs.callPackage ./proxy-profile-switch.nix { };
    in
    {
      home.packages = [
        pactl-listner
        sync-music
        close-special-workspace
        get-weather
        bitwarden-handler
        proxy-status
        proxy-switch
        proxy-profile-switch
      ];
    };
in
[ scripts ]
