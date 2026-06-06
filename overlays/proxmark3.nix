{ proxmark3, fetchFromGitHub }:

let
  version = "4.20728";

  base = proxmark3.override {
    withGeneric = true;
    hardwarePlatformExtras = "FLASH";
  };
in
base.overrideAttrs (old: {
  inherit version;

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "proxmark3";
    rev = "v${version}";
    hash = "sha256-dmWPi5xOcXXdvUc45keXGUNhYmQEzAHbKexpDOwIHhE=";
  };

  makeFlags = old.makeFlags ++ [ "LED_ORDER=PM3EASY" ];
})
