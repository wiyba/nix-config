{ pkgs, config, ... }:

{
  home.packages = with pkgs; [ ncmpcpp mpd ffmpeg inotify-tools ];

  home.file.".config/mpd/mpd.conf".text = ''
    music_directory         "~/Music"
    playlist_directory      "~/.config/mpd/playlists"
    db_file                 "~/.config/mpd/database"
    log_file                "~/.config/mpd/log"
    pid_file                "~/.config/mpd/pid"
    state_file              "~/.config/mpd/state"
    sticker_file            "~/.config/mpd/sticker.sql"

    bind_to_address         "localhost"
    port                    "6600"

    auto_update             "yes"
    max_connections         "10"
    audio_buffer_size       "4096"
    buffer_before_play      "10%"

    audio_output {
      type                  "pulse"
      name                  "PulseAudio"
      format                "48000:24:2"
    }
  '';

  home.file.".config/ncmpcpp/config".text = ''
    mpd_host                = "localhost"
    mpd_port                = "6600"

    colors_enabled          = yes
  '';

  systemd.user.services.mpd = {
    Unit.Description = "Music Player Daemon";
    Service.ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${config.home.homeDirectory}/.config/mpd/mpd.conf";
    Service.Restart = "on-failure";
    Install.WantedBy = [ "default.target" ];
  };
}

