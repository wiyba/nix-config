{ pkgs, lib, ... }:
let
  username = "wiyba";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  nerdFonts = with pkgs.nerd-fonts; [
    symbols-only
    caskaydia-cove
  ];

  fontPkgs =
    with pkgs;
    [
      font-awesome
      material-design-icons
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ]
    ++ nerdFonts;

  packages = with pkgs; [
    age # age
    any-nix-shell # zsh support for nix shell
    appimage-run # tool to run appimage in nixos
    btop # htop but better
    claude-code # cli llm
    discord-canary # another messanger
    easyeffects # best eq app
    eza # ls but better
    file # file
    filezilla # sftp gui client
    jq # json parser
    nemo # file manager
    mtr # better traceroute
    nil # lsp for nix
    nitch # preconfigured fastfetch
    ntfs3g # ntfs driver
    packwiz # minecraft modpacks manager
    prismlauncher # minecraft launcher
    sops # sops
    supersonic-wayland # music player for subsonic api
    telegram-desktop # messanger
    unzip # decompress files
    vlc # media player
    vscode # code editor
    zip # compress files
  ] ++ fontPkgs;

in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../packages
    ../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      download = "${homeDirectory}/Downloads";
      videos = "${homeDirectory}/Videos";
      music = "${homeDirectory}/Music";
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
          firefox = "firefox-beta.desktop";
          vlc = "vlc.desktop";
          code = "code.desktop";
        in
        lib.genAttrs [
          "video/mp4"
          "video/x-matroska"
          "video/webm"
          "video/x-msvideo"
          "video/quicktime"
          "video/mpeg"
          "video/x-flv"
          "video/ogg"
          "video/3gpp"
          "video/x-ogm+ogg"
          "audio/mpeg"
          "audio/flac"
          "audio/ogg"
          "audio/wav"
          "audio/x-wav"
          "audio/aac"
          "audio/mp4"
          "audio/x-vorbis+ogg"
          "audio/webm"
        ] (_: vlc)
        // lib.genAttrs [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/pdf"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ] (_: firefox)
        // lib.genAttrs [
          "text/plain"
          "text/x-python"
          "text/x-shellscript"
          "text/x-csrc"
          "text/x-chdr"
          "text/x-c++src"
          "text/x-java"
          "text/javascript"
          "text/css"
          "text/markdown"
          "text/x-rust"
          "text/x-go"
          "application/json"
          "application/xml"
          "application/x-yaml"
          "application/toml"
          "application/x-zerosize"
        ] (_: code);
    };
  };

  home = {
    inherit username homeDirectory packages;

    sessionVariables = {
      BROWSER = "${lib.getExe pkgs.firefox-beta}";
      DISPLAY = ":0";
      SHELL = "${lib.getExe pkgs.zsh}";
      EDITOR = "nvim";
      VISUAL = "code --wait";
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
