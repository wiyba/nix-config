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
      bun # bun
      claude-code # cli llm
      eza # ls but better
      file # file
      filezilla # sftp gui client
      gh # github cli
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
      rkn-block-checker # internet block diagnosis tool
      supersonic-wayland # music player for subsonic api
      telegram-desktop # messanger
      terminal-oscilloscope # terminal-oscilloscope
      unar # decompress files
      vlc # media player
      zip # compress files
      osu-lazer-bin # circles gaem
      dex # .config/autostart helper for WMs
      obs-cmd # cli for obs binds in wm
      streamrip # music downloader for qobuz
      libreoffice-fresh # office app for ege(?)
      wireshark # wireshark
      scrcpy # android screen mirroring
      localsend # local file sharing
      gnirehtet # android reverse tethering
      blender # 3d modeling
      pinta # image editor
      audacity # audio editor
      r2modman # modding tool
    ]
    ++ fontPkgs;

in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../scripts/shared
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
          terminal = "kitty.desktop";
          prism = "org.prismlauncher.PrismLauncher.desktop";
          telegram = "org.telegram.desktop.desktop";
          appimage = "appimage-run.desktop";
          office = app: "libreoffice-${app}.desktop";

          each = app: types: lib.genAttrs types (_: app);
        in
        lib.mergeAttrsList [
          (each browser [
            "text/html"
            "text/xml"
            "application/xhtml+xml"
            "application/xml"
            "application/rdf+xml"
            "application/rss+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/chromium"
            "application/pdf"
            "image/png"
            "image/jpeg"
            "image/gif"
            "image/webp"
            "image/avif"
            "image/bmp"
            "image/svg+xml"
            "image/vnd.microsoft.icon"
          ])
          (each viewer [
            "image/tiff"
            "image/svg+xml-compressed"
            "image/jxl"
            "image/heic"
            "image/qoi"
            "image/vnd-ms.dds"
            "image/vnd.radiance"
            "image/x-dds"
            "image/x-exr"
            "image/x-portable-anymap"
            "image/x-portable-bitmap"
            "image/x-portable-graymap"
            "image/x-portable-pixmap"
            "image/x-qoi"
            "image/x-tga"
          ])
          (each editor [
            "text/plain"
            "text/markdown"
            "text/css"
            "text/javascript"
            "text/x-c"
            "text/x-c++"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-go"
            "text/x-java"
            "text/x-makefile"
            "text/x-moc"
            "text/x-pascal"
            "text/x-python"
            "text/x-rust"
            "text/x-tcl"
            "text/x-tex"
            "text/english"
            "application/json"
            "application/toml"
            "application/x-yaml"
            "application/x-zerosize"
          ])
          (each terminal [
            "application/x-sh"
            "application/x-shellscript"
          ])
          (each archive [
            "application/zip"
            "application/x-tar"
            "application/x-compressed-tar"
            "application/x-bzip-compressed-tar"
            "application/x-xz-compressed-tar"
            "application/x-zstd-compressed-tar"
            "application/gzip"
            "application/x-7z-compressed"
            "application/x-rar"
            "application/x-rar-compressed"
            "application/vnd.rar"
            "application/x-cd-image"
          ])
          (each player [
            "audio/aac"
            "audio/ac3"
            "audio/basic"
            "audio/flac"
            "audio/m4a"
            "audio/midi"
            "audio/mp3"
            "audio/mp4"
            "audio/mpeg"
            "audio/mpegurl"
            "audio/ogg"
            "audio/opus"
            "audio/vorbis"
            "audio/wav"
            "audio/webm"
            "audio/x-aac"
            "audio/x-aiff"
            "audio/x-ape"
            "audio/x-flac"
            "audio/x-m4a"
            "audio/x-matroska"
            "audio/x-mp3"
            "audio/x-mpeg"
            "audio/x-mpegurl"
            "audio/x-ms-wma"
            "audio/x-musepack"
            "audio/x-pn-realaudio"
            "audio/x-vorbis+ogg"
            "audio/x-wav"
            "audio/x-wavpack"
            "video/3gpp"
            "video/3gpp2"
            "video/avi"
            "video/divx"
            "video/dv"
            "video/mp2t"
            "video/mp4"
            "video/mpeg"
            "video/ogg"
            "video/quicktime"
            "video/webm"
            "video/x-avi"
            "video/x-flv"
            "video/x-m4v"
            "video/x-matroska"
            "video/x-mpeg"
            "video/x-ms-wmv"
            "video/x-msvideo"
            "video/x-ogm+ogg"
            "video/x-theora+ogg"
          ])
          {
            "inode/directory" = "nemo.desktop";

            "x-scheme-handler/steam" = "steam.desktop";
            "x-scheme-handler/steamlink" = "steam.desktop";
            "x-scheme-handler/tg" = telegram;
            "x-scheme-handler/tonsite" = telegram;
            "x-scheme-handler/discord" = "com.discordapp.Discord.desktop";
            "x-scheme-handler/prismlauncher" = prism;
            "x-scheme-handler/curseforge" = prism;
            "x-scheme-handler/vscode" = "code-url-handler.desktop";
            "x-scheme-handler/zed" = editor;
            "x-scheme-handler/albert" = "albert.desktop";

            "application/x-modrinth-modpack+zip" = prism;

            "application/vnd.appimage" = appimage;
            "application/x-iso9660-appimage" = appimage;

            "application/vnd.oasis.opendocument.spreadsheet" = office "calc";
            "application/vnd.oasis.opendocument.text" = office "writer";
            "application/vnd.oasis.opendocument.presentation" = office "impress";
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = office "calc";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = office "writer";
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = office "impress";
            "application/msword" = office "writer";
            "application/vnd.ms-excel" = office "calc";
            "application/vnd.ms-powerpoint" = office "impress";
          }
        ];
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

    pointerCursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };
    "org/nemo/preferences".show-open-in-terminal-toolbar = true;
  };

  gtk = {
    enable = true;
    gtk4.theme = null;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.user.startServices = "sd-switch";
  news.display = "silent";
}
