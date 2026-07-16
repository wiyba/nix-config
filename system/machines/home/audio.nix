{ pkgs, ... }:

# TODO: remove unnecessary things
{
  services.pipewire.extraLadspaPackages = [
    pkgs.ladspaPlugins
    pkgs.rnnoise-plugin.ladspa
  ];

  services.pipewire.wireplumber.extraConfig."51-ur22c" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-output-0"; }
        ];
        actions.update-props = {
          "node.description" = "UR22C Output";
          "priority.driver" = 5000;
          "priority.session" = 5000;
          "api.alsa.disable-tsched" = false;
        };
      }
      {
        matches = [
          { "node.name" = "alsa_input.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-input-0"; }
        ];
        actions.update-props = {
          "priority.driver" = 5000;
          "priority.session" = 5000;
          "api.alsa.disable-tsched" = false;
        };
      }
    ];
  };

  services.pipewire.extraConfig.pipewire."20-elgato-loopback" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "Elgato 4K X Loopback";
          "capture.props" = {
            "node.name" = "elgato_4kx_capture";
            "target.object" = "alsa_input.usb-Elgato_Elgato_4K_X_A7SNB60130I2V4-02.analog-stereo";
            "node.dont-reconnect" = true;
            "stream.dont-remix" = true;
            "audio.position" = [ "FL" "FR" ];
          };
          "playback.props" = {
            "node.name" = "elgato_4kx_playback";
            "target.object" = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-output-0";
            "node.dont-reconnect" = true;
            "audio.position" = [ "FL" "FR" ];
          };
        };
      }
    ];
  };

  services.pipewire.extraConfig.pipewire."20-ur22c-voice" = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "UR22C Input";
          "media.name" = "UR22C Input";
          "filter.graph" = {
            nodes = [
              { type = "builtin"; name = "mix"; label = "mixer"; }
              { type = "builtin"; name = "hpf"; label = "bq_highpass"; control = { "Freq" = 150.0; "Q" = 0.707; }; }
              {
                type = "ladspa";
                name = "rnnoise";
                plugin = "librnnoise_ladspa";
                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 50.0;
                  "VAD Grace Period (ms)" = 600;
                  "Retroactive VAD Grace (ms)" = 350;
                };
              }
              {
                type = "ladspa";
                name = "gate";
                plugin = "gate_1410";
                label = "gate";
                control = {
                  "Threshold (dB)" = -28.0;
                  "Attack (ms)" = 2.0;
                  "Hold (ms)" = 500.0;
                  "Decay (ms)" = 250.0;
                  "Range (dB)" = -25.0;
                };
              }
              {
                type = "ladspa";
                name = "comp";
                plugin = "sc1_1425";
                label = "sc1";
                control = {
                  "Attack time (ms)" = 8.0;
                  "Release time (ms)" = 200.0;
                  "Threshold level (dB)" = -38.0;
                  "Ratio (1:n)" = 5.0;
                  "Knee radius (dB)" = 8.0;
                  "Makeup gain (dB)" = 10.0;
                };
              }
              {
                type = "ladspa";
                name = "limit";
                plugin = "fast_lookahead_limiter_1913";
                label = "fastLookaheadLimiter";
                control = {
                  "Input gain (dB)" = -1.0;
                  "Limit (dB)" = -3.0;
                  "Release time (s)" = 0.15;
                };
              }
            ];
            inputs = [ "mix:In 1" "mix:In 2" ];
            outputs = [ "limit:Output 1" ];
            links = [
              { output = "mix:Out"; input = "hpf:In"; }
              { output = "hpf:Out"; input = "rnnoise:Input"; }
              { output = "rnnoise:Output"; input = "gate:Input"; }
              { output = "gate:Output"; input = "comp:Input"; }
              { output = "comp:Output"; input = "limit:Input 1"; }
              { output = "comp:Output"; input = "limit:Input 2"; }
            ];
          };
          "audio.channels" = 1;
          "audio.position" = [ "MONO" ];
          "capture.props" = {
            "node.name" = "ur22c_voice_capture";
            "target.object" = "alsa_input.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-input-0";
            "audio.channels" = 2;
            "audio.position" = [ "FL" "FR" ];
            "stream.dont-remix" = true;
          };
          "playback.props" = {
            "node.name" = "ur22c_voice_source";
            "node.description" = "UR22C Input";
            "media.class" = "Audio/Source";
            "audio.channels" = 1;
            "audio.position" = [ "MONO" ];
            "priority.session" = 3000;
            "priority.driver" = 3000;
          };
        };
      }
    ];
  };
}
