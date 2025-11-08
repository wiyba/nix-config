{ ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/wiyba/Music";
    extraConfig = ''
      audio_output {
        type   "pipewire"
        name   "PipeWire 48k"
        format "48000:32:2"
      }
    '';
  };
}
