{ pkgs, ... }:

let
  zashboard = pkgs.fetchFromGitHub {
    owner = "Zephyruso";
    repo = "zashboard";
    rev = "refs/heads/gh-pages";
    sha256 = "sha256-qQgW9fpd1us/Qtk27hjLrR/ouBwhlo7LXvwMRWt5jFc=";
  };
in
{
  services.mihomo = {
    enable = true;
    configFile = "/etc/mihomo/config.yaml";
    webui = zashboard;
  };
}
