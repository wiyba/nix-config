{ lib, inputs, host, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell.enable = true;

  home.activation.noctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/noctalia
    ln -sf /etc/nixos/home/programs/noctalia/${host}.json $HOME/.config/noctalia/settings.json
  '';
}
