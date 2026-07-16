{ host, ... }:
{
  imports = {
    home = [ ./secrets.nix ./xray.nix ./admin.nix ./mihomo.nix ./xcli.nix ];
    thinkpad = [ ./secrets.nix ./mihomo.nix ];
    stockholm = [ ./secrets.nix ./xray.nix ./admin.nix ./mihomo.nix ];
    almaty = [ ./secrets.nix ./xray.nix ./admin.nix ./mihomo.nix ];
  }.${host} or [ ];
}
