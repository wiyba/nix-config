{ pkgs, inputs, ... }:

{
  programs.spicetify = {
    enable = true;
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.comfy // {
      # injectCss = true;
      # injectThemeJs = true;
      # replaceColors = true;
      # homeConfig = true;
      # overwriteAssets = false;
    };
    colorScheme = "Mono";
  };
}
