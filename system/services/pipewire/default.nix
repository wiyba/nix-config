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

  services.pipewire.extraConfig.pipewire."10-sample-rate" = lib.mkIf (host == "home") {
    "context.properties" = {
      "default.clock.rate" = 48000;
      # 256 samples @ 48kHz = ~5.3ms латентность (хорошо для голоса)
      "default.clock.quantum" = 256;
      "default.clock.min-quantum" = 256;
    };
  };

  # UR22C: использовать analog stereo + surround 4.0 профиль
  # и создать виртуальный mono source только из XLR входов (без loopback)
  services.pipewire.wireplumber.extraConfig."10-ur22c" = lib.mkIf (host == "home") {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "~alsa_card.usb-Yamaha_Corporation_Steinberg_UR22C.*"; }
        ];
        actions = {
          update-props = {
            # Analog Stereo Output + Analog Surround 4.0 Input
            "device.profile" = "output:analog-stereo+input:analog-surround-40";
          };
        };
      }
    ];
  };

  # Виртуальный mono source: берёт только FL+FR (XLR входы), игнорирует loopback (RL+RR)
  services.pipewire.extraConfig.pipewire."20-ur22c-xlr-mono" = lib.mkIf (host == "home") {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "UR22C XLR Mono";
          "capture.props" = {
            "node.name" = "ur22c-xlr-capture";
            "media.class" = "Stream/Output/Audio";
            "audio.position" = [ "FL" "FR" ];
            "stream.capture.sink" = true;
            "node.target" = "alsa_input.usb-Yamaha_Corporation_Steinberg_UR22C-00.analog-surround-40";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "ur22c-xlr-mono";
            "media.class" = "Audio/Source";
            "audio.position" = [ "MONO" ];
          };
        };
      }
    ];
  };
}
