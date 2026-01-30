{ pkgs, ... }:
{
  home.packages = [ pkgs.musicpresence ];
  xdg.dataFile."Music Presence/settings.json".text = ''
    {
      "version": 1,
      "experimental": {
        "presence_update_limiter_count": null,
        "presence_update_limiter_time_frame": null
      },
      "language": null,
      "enabled": true,
      "disable_all_players_by_default": false,
      "default_discord_application_id": null,
      "presence": {
        "show_branding": false,
        "show_player_logo": false,
        "show_paused_media": false,
        "show_paused_media_duration": true,
        "show_paused_media_timestamp": false,
        "show_media_playing_icon": false,
        "show_media_paused_icon": true,
        "swap_title_and_artist": false,
        "single_line": false,
        "artist_album_line": false,
        "display_type": "artist_line",
        "profile_display_type": "player_name",
        "custom_discord_application_id": null,
        "activity_type": "listening",
        "describe_artist": false,
        "describe_album": false,
        "show_album_name": true,
        "show_playback_duration": true,
        "show_no_song_information": false,
        "no_cover_placeholder": "music_note",
        "show_album_with_empty_artist": true,
        "show_alternative_song_link_button": false,
        "saved_profiles": {},
        "disabled_discord_users_mapping": []
      },
      "features": {
        "proxy_cover_images": true,
        "always_proxy_cover_images": false
      },
      "external_services": {
        "tidal": true,
        "deezer": true,
        "spotify": true,
        "apple_music": true,
        "itunes": false,
        "musicbrainz": false
      },
      "music_api_configuration": {
        "get_additional_artists": true,
        "get_album_covers": true,
        "get_animated_album_covers": false,
        "guess_album": true,
        "localize_results": true,
        "country_code": null
      },
      "miscellaneous": {
        "show_tray_icon": false,
        "open_settings_when_launched_again": true,
        "remember_last_opened_settings_panel": true,
        "show_update_popups": false,
        "show_first_launch_changelog": false,
        "tray_icon_theme_override": "light",
        "tray_menu_theme_override": "dark",
        "show_news_popups": false,
        "autostart": null
      },
      "advanced": {
        "media_detection": "system_interfaces"
      },
      "player_settings": {
        "spotify_filter_advertisements": true,
        "spotify_always_use_podcast_activity_name": false,
        "spotify_only_show_podcasts": false,
        "spotify_never_show_podcasts": false,
        "apple_music_split_album_artist": true,
        "deezer_filter_advertisements": true,
        "deezer_always_use_podcast_activity_name": false,
        "player_mapping": {}
      },
      "player_overrides": {
        "well_known": {}
      },
      "players": {
        "well_known": {
          "youtube": {
            "enabled": false,
            "user_modified": false
          },
          "supersonic": {
            "enabled": true,
            "user_modified": false
          }
        }
      }
    }
  '';
}