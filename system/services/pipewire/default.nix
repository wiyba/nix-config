{ ... }:
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
}
