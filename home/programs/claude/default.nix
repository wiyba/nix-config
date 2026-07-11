{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.claude-code ];

  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.claude
    ln -sf /etc/nixos/home/programs/claude/settings.json $HOME/.claude/settings.json
    ln -sf /etc/nixos/home/programs/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
  '';
}
