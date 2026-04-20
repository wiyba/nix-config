{ pkgs, lib, ... }:
let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  nerdFonts = with pkgs.nerd-fonts; [
    symbols-only
    caskaydia-cove
    jetbrains-mono
  ];

  fontPkgs =
    with pkgs;
    [
      font-awesome
      material-design-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ]
    ++ nerdFonts;

  packages =
    with pkgs;
    [
      age # age
      any-nix-shell # zsh support for nix shell
      appimage-run # tool to run appimage in nixos
      claude-code # cli llm
      discord-canary # another messanger
      eza # ls but better
      file # file
      filezilla # sftp gui client
      jq # json parser
      nemo # file manager
      file-roller # archive manager
      hyprpolkitagent # polkit auth agent
      mtr # better traceroute
      nil # lsp for nix
      nitch # preconfigured fastfetch
      ntfs3g # ntfs driver
      packwiz # minecraft modpacks manager
      prismlauncher # minecraft launcher
      sops # sops
      loupe # image viewer
      mediainfo # media info
      theclicker # autoclicker
      volatility3 # mem dump viewer
      flac # tagging support
      sqlite # cli sqlite db viewer
      scanmem # memory scanner
      xrdb # xrdb for setting Xft.dpi
      dnsutils # dnsutils
      tcpdump # tcp dump
      python3 # python3
      supersonic-wayland # music player for subsonic api
      telegram-desktop # messanger
      unzip # decompress files
      unar # decompress files but better
      vlc # media player
      vscode # code editor
      zip # compress files
      qbittorrent # best and only torrent client
      osu-lazer-bin # circles gaem
      dex # .config/autostart helper for WMs
      obs-cmd # cli for obs binds in wm
      streamrip # music downloader for qobuz
      libreoffice-fresh # office app for ege(?)
      wireshark # wireshark
    ]
    ++ fontPkgs;

in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../scripts
    ../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;

    configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

    userDirs = {
      enable = true;
      setSessionVariables = false;
      createDirectories = true;
      download = "${homeDirectory}/Downloads";
      videos = "${homeDirectory}/Videos";
      music = homeDirectory;
      pictures = "${homeDirectory}/Pictures";
      desktop = homeDirectory;
      documents = homeDirectory;
      publicShare = homeDirectory;
      templates = homeDirectory;
    };

    mimeApps = {
      enable = true;
      defaultApplications =
        let
          browser = "firefox-beta.desktop";
          editor = "dev.zed.Zed.desktop";
          viewer = "org.gnome.Loupe.desktop";
          player = "vlc.desktop";
          archive = "org.gnome.FileRoller.desktop";
          files = "nemo.desktop";
          terminal = "kitty.desktop";
        in
        {
          "text/html" = browser;
          "text/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/chromium" = browser;
          "application/pdf" = browser;

          "image/png" = browser;
          "image/jpeg" = browser;
          "image/gif" = browser;
          "image/webp" = browser;
          "image/avif" = browser;
          "image/bmp" = browser;
          "image/svg+xml" = browser;
          "image/vnd.microsoft.icon" = browser;

          "image/tiff" = viewer;
          "image/svg+xml-compressed" = viewer;
          "image/jxl" = viewer;
          "image/heic" = viewer;
          "image/qoi" = viewer;
          "image/vnd-ms.dds" = viewer;
          "image/vnd.radiance" = viewer;
          "image/x-dds" = viewer;
          "image/x-exr" = viewer;
          "image/x-portable-anymap" = viewer;
          "image/x-portable-bitmap" = viewer;
          "image/x-portable-graymap" = viewer;
          "image/x-portable-pixmap" = viewer;
          "image/x-qoi" = viewer;
          "image/x-tga" = viewer;

          "text/plain" = editor;
          "text/markdown" = editor;
          "text/css" = editor;
          "text/javascript" = editor;
          "text/x-c" = editor;
          "text/x-c++" = editor;
          "text/x-c++hdr" = editor;
          "text/x-c++src" = editor;
          "text/x-chdr" = editor;
          "text/x-csrc" = editor;
          "text/x-go" = editor;
          "text/x-java" = editor;
          "text/x-makefile" = editor;
          "text/x-moc" = editor;
          "text/x-pascal" = editor;
          "text/x-python" = editor;
          "text/x-rust" = editor;
          "text/x-tcl" = editor;
          "text/x-tex" = editor;
          "text/english" = editor;
          "application/json" = editor;
          "application/toml" = editor;
          "application/x-yaml" = editor;
          "application/x-zerosize" = editor;

          "application/x-sh" = terminal;
          "application/x-shellscript" = terminal;

          "application/zip" = archive;
          "application/x-tar" = archive;
          "application/x-compressed-tar" = archive;
          "application/x-bzip-compressed-tar" = archive;
          "application/x-xz-compressed-tar" = archive;
          "application/x-zstd-compressed-tar" = archive;
          "application/gzip" = archive;
          "application/x-7z-compressed" = archive;
          "application/x-rar" = archive;
          "application/x-rar-compressed" = archive;
          "application/vnd.rar" = archive;
          "application/x-cd-image" = archive;

          "audio/aac" = player;
          "audio/ac3" = player;
          "audio/basic" = player;
          "audio/flac" = player;
          "audio/m4a" = player;
          "audio/midi" = player;
          "audio/mp3" = player;
          "audio/mp4" = player;
          "audio/mpeg" = player;
          "audio/mpegurl" = player;
          "audio/ogg" = player;
          "audio/opus" = player;
          "audio/vorbis" = player;
          "audio/wav" = player;
          "audio/webm" = player;
          "audio/x-aac" = player;
          "audio/x-aiff" = player;
          "audio/x-ape" = player;
          "audio/x-flac" = player;
          "audio/x-m4a" = player;
          "audio/x-matroska" = player;
          "audio/x-mp3" = player;
          "audio/x-mpeg" = player;
          "audio/x-mpegurl" = player;
          "audio/x-ms-wma" = player;
          "audio/x-musepack" = player;
          "audio/x-pn-realaudio" = player;
          "audio/x-vorbis+ogg" = player;
          "audio/x-wav" = player;
          "audio/x-wavpack" = player;

          "video/3gpp" = player;
          "video/3gpp2" = player;
          "video/avi" = player;
          "video/divx" = player;
          "video/dv" = player;
          "video/mp2t" = player;
          "video/mp4" = player;
          "video/mpeg" = player;
          "video/ogg" = player;
          "video/quicktime" = player;
          "video/webm" = player;
          "video/x-avi" = player;
          "video/x-flv" = player;
          "video/x-m4v" = player;
          "video/x-matroska" = player;
          "video/x-mpeg" = player;
          "video/x-ms-wmv" = player;
          "video/x-msvideo" = player;
          "video/x-ogm+ogg" = player;
          "video/x-theora+ogg" = player;

          "inode/directory" = files;

          "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
          "x-scheme-handler/magnet" = "org.qbittorrent.qBittorrent.desktop";

          "x-scheme-handler/steam" = "steam.desktop";
          "x-scheme-handler/steamlink" = "steam.desktop";
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
          "x-scheme-handler/discord" = "discord-canary.desktop";
          "x-scheme-handler/prismlauncher" = "org.prismlauncher.PrismLauncher.desktop";
          "x-scheme-handler/curseforge" = "org.prismlauncher.PrismLauncher.desktop";
          "x-scheme-handler/vscode" = "code-url-handler.desktop";
          "x-scheme-handler/zed" = "dev.zed.Zed.desktop";
          "x-scheme-handler/albert" = "albert.desktop";

          "application/x-modrinth-modpack+zip" = "org.prismlauncher.PrismLauncher.desktop";

          "application/vnd.appimage" = "appimage-run.desktop";
          "application/x-iso9660-appimage" = "appimage-run.desktop";

          "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
          "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
          "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            "libreoffice-writer.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            "libreoffice-impress.desktop";
          "application/msword" = "libreoffice-writer.desktop";
          "application/vnd.ms-excel" = "libreoffice-calc.desktop";
          "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
        };
    };
  };

  home = {
    inherit username homeDirectory packages;

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox-beta}";
      DISPLAY = ":0";
      SHELL = "${lib.getExe pkgs.zsh}";
      GIT_ASKPASS = "";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.user.startServices = "sd-switch";
  news.display = "silent";
}
