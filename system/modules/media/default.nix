{ config, ... }:

{
  users.groups.media = {};

  services.jellyfin = {
    enable = true;
    group = "media";
    dataDir = "/media/jellyfin";

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    transcoding = {
      enableHardwareEncoding = true;
      enableToneMapping = true;
      enableSubtitleExtraction = true;

      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        vp9 = true;
        av1 = true;
      };

      hardwareEncodingCodecs = {
        hevc = true;
        av1 = true;
      };
    };
  };

  services.navidrome = {
    enable = true;
    group = "media";
    settings = {
      DataFolder = "/media/navidrome";
      MusicFolder = "/media/music";
      PlaylistsPath = "/media/navidrome/playlists";
      UILoginBackgroundUrl = "https://i.pinimg.com/736x/b0/fc/d9/b0fcd999b0e3d3f3ef4336db0e218838.jpg";
      "LastFM.Enabled" = true;
      "LastFM.Language" = "ru";
    };
  };

  systemd.services.navidrome.serviceConfig.EnvironmentFile = config.sops.secrets.navidrome-env.path;
  users.users.jellyfin.extraGroups = [ "video" "render" ];
}
