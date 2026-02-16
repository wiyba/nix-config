{ lib, host, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire = {
      "11-resample-quality" = {
        "stream.properties" = {
          "resample.quality" = 10;
        };
      };
    };
  };

  # home-specific sample rate
  services.pipewire.extraConfig.pipewire."10-sample-rate" = lib.mkIf (host == "home") {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
    };
  };
}
