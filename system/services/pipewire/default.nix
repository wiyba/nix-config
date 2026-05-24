{ lib, pkgs, host, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    extraLadspaPackages = lib.mkIf (host == "home") [ pkgs.ladspaPlugins ];
  };

  services.pipewire.extraConfig.pipewire."10-sample-rate" = lib.mkIf (host == "home") {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 2048;
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 4096;
    };
  };

  services.pipewire.wireplumber.extraConfig."51-ur22c-playback-master" = lib.mkIf (host == "home") {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-output-0"; }
        ];
        actions.update-props = {
          "priority.driver" = 5000;
          "priority.session" = 5000;
        };
      }
    ];
  };

  services.pipewire.extraConfig.pipewire."20-ur22c-voice" = lib.mkIf (host == "home") {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "UR22C Voice";
          "media.name" = "UR22C Voice";
          "filter.graph" = {
            nodes = [
              { type = "builtin"; name = "mix"; label = "mixer"; }
              { type = "builtin"; name = "hpf"; label = "bq_highpass"; control = { "Freq" = 80.0; "Q" = 0.707; }; }
              {
                type = "ladspa";
                name = "gate";
                plugin = "gate_1410";
                label = "gate";
                control = {
                  "Threshold (dB)" = -28.0;
                  "Attack (ms)" = 1.0;
                  "Hold (ms)" = 200.0;
                  "Decay (ms)" = 300.0;
                  "Range (dB)" = -90.0;
                };
              }
              {
                type = "ladspa";
                name = "comp";
                plugin = "sc1_1425";
                label = "sc1";
                control = {
                  "Attack time (ms)" = 3.0;
                  "Release time (ms)" = 200.0;
                  "Threshold level (dB)" = -22.0;
                  "Ratio (1:n)" = 4.0;
                  "Knee radius (dB)" = 6.0;
                  "Makeup gain (dB)" = 4.0;
                };
              }
              {
                type = "ladspa";
                name = "limit";
                plugin = "fast_lookahead_limiter_1913";
                label = "fastLookaheadLimiter";
                control = {
                  "Input gain (dB)" = 0.0;
                  "Limit (dB)" = -3.0;
                  "Release time (s)" = 0.05;
                };
              }
            ];
            inputs = [ "mix:In 1" "mix:In 2" ];
            outputs = [ "limit:Output 1" ];
            links = [
              { output = "mix:Out"; input = "hpf:In"; }
              { output = "hpf:Out"; input = "gate:Input"; }
              { output = "gate:Output"; input = "comp:Input"; }
              { output = "comp:Output"; input = "limit:Input 1"; }
              { output = "comp:Output"; input = "limit:Input 2"; }
            ];
          };
          "audio.channels" = 1;
          "audio.position" = [ "MONO" ];
          "capture.props" = {
            "node.name" = "ur22c_voice_capture";
            "node.target" = "alsa_input.usb-Yamaha_Corporation_Steinberg_UR22C-00.pro-input-0";
            "audio.channels" = 2;
            "audio.position" = [ "FL" "FR" ];
            "stream.dont-remix" = true;
          };
          "playback.props" = {
            "node.name" = "ur22c_voice_source";
            "node.description" = "UR22C Voice";
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
