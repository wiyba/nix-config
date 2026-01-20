{ pkgs, ... }:

let
  zashboard = pkgs.fetchFromGitHub {
    owner = "Zephyruso";
    repo = "zashboard";
    rev = "refs/heads/gh-pages";
    sha256 = "sha256-WiTSub2cdVqtuviz7wIoShA5DMXqsOVn2SwVwLEKtPA=";
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
