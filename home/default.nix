{ inputs, pkgs, system, ... }:
let
  mkHome = mods: inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = mods;
  };
in
{
  "wiyba@ms-7c39" = mkHome [ ./wm/hyprland/home.nix ];
  "wiyba@nix-usb" = mkHome [ ./wm/hyprland/home.nix ];
  "wiyba@thinkpad-x1" = mkHome [ ./wm/hyprland/home.nix ];
}
