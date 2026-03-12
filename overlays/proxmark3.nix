{ proxmark3, fetchFromGitHub }:

(proxmark3.override {
  withGeneric = true;
  hardwarePlatformExtras = "FLASH";
}).overrideAttrs
  (old: {
    version = "4.20728";
    src = fetchFromGitHub {
      owner = "RfidResearchGroup";
      repo = "proxmark3";
      rev = "v4.20728";
      hash = "sha256-dmWPi5xOcXXdvUc45keXGUNhYmQEzAHbKexpDOwIHhE=";
    };
    makeFlags = old.makeFlags ++ [ "LED_ORDER=PM3EASY" ];
  })
