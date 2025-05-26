{ pkgs, ... }:

pkgs.writeShellScriptBin "show-zombie-parents" ''
  ps -A -ostat,ppid | grep -e '[zZ]'| awk '{ print $2 }' | uniq | xargs ps -p
''