{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--load-extension=${./weba-search}"
      "--force-dark-mode"
    ];
  };
}
