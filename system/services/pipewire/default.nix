{ lib, host, ... }:

{
  security.rtkit.enable = true;

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
      "default.clock.quantum" = 2048;
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 4096;
    };
  };

  services.pipewire.wireplumber.extraConfig."10-ur22c" = lib.mkIf (host == "home") {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "~alsa_card.usb-Yamaha_Corporation_Steinberg_UR22C.*"; }
        ];
        actions = {
          update-props = {
            "device.profile" = "output:analog-stereo+input:analog-surround-40";
          };
        };
      }
    ];
  };

  #thinkpad speakers optimizer by claude cus im too lazy to get impulse from win
  services.pipewire.extraConfig.pipewire."50-speaker-dsp" = lib.mkIf (host == "thinkpad") {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Speakers";
          "media.name" = "Speakers";
          "filter.graph" = {
            nodes = [
              { type = "builtin"; name = "hpf_1"; label = "bq_highpass"; control = { "Freq" = 100.0; "Q" = 0.707; }; }
              { type = "builtin"; name = "hpf_2"; label = "bq_highpass"; control = { "Freq" = 100.0; "Q" = 0.707; }; }
              { type = "builtin"; name = "eq_1"; label = "bq_peaking"; control = { "Freq" = 469.0; "Q" = 2.9; "Gain" = -4.0; }; }
              { type = "builtin"; name = "eq_2"; label = "bq_peaking"; control = { "Freq" = 656.0; "Q" = 3.5; "Gain" = -2.5; }; }
            ];
            links = [
              { output = "hpf_1:Out"; input = "hpf_2:In"; }
              { output = "hpf_2:Out"; input = "eq_1:In"; }
              { output = "eq_1:Out";  input = "eq_2:In"; }
            ];
          };
          "audio.channels" = 2;
          "audio.position" = [ "FL" "FR" ];
          "capture.props" = {
            "node.name" = "effect_input.speaker_dsp";
            "media.class" = "Audio/Sink";
            "priority.session" = 1100;
            "priority.driver" = 1100;
          };
          "playback.props" = {
            "node.name" = "effect_output.speaker_dsp";
            "node.target" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
            "node.passive" = true;
          };
        };
      }
    ];
  };

  #custom node for my audiocard cus builtin not working right for me
  services.pipewire.extraConfig.pipewire."20-ur22c-xlr-mono" = lib.mkIf (host == "home") {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "UR22C XLR Mono";
          "capture.props" = {
            "node.name" = "ur22c-xlr-capture";
            "audio.channels" = 2;
            "audio.position" = [ "FL" "FR" ];
            "stream.dont-remix" = true;
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
