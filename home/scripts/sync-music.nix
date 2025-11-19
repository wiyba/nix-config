{ writeShellScriptBin, pkgs, ... }:
let
  rsync = "${pkgs.rsync}/bin/rsync";
  dir = "/home/wiyba/Music/";
in
writeShellScriptBin "sync-music" ''
  ${rsync} -avz --delete root@home.wiyba.org:/opt/navidrome/ ${dir}
''

