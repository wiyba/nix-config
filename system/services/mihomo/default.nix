{ pkgs, ... }:

let
  zashboard = pkgs.fetchFromGitHub {
    owner = "Zephyruso";
    repo = "zashboard";
    rev = "refs/heads/gh-pages";
    sha256 = "sha256-2BFP9URULo4jRjpuLG0PZwMMeghsHMI0ZuuGGZ4FOng=";
  };
in
{
  services.mihomo = {
    enable = true;
    configFile = "/etc/mihomo/config.yaml";
    webui = zashboard;
    tunMode = true;
  };
}
