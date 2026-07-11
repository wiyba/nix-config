{ host, lib, ... }:
let
  roles = {
    home = [ ./xray.nix ./mihomo-client.nix ./xcli.nix ];
    thinkpad = [ ./mihomo-client.nix ];
    helsinki = [ ./xray.nix ./mihomo-chain.nix ];
    stockholm = [ ./xray.nix ./mihomo-chain.nix ];
    almaty = [ ./xray.nix ./mihomo-chain.nix ];
  };
  active = roles.${host} or [ ];
in
{
  imports = active ++ lib.optional (active != [ ]) ./secrets.nix;
}
