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
      vlc # media player
      vscode # code editor
      zip # compress files
      qbittorrent # best and only torrent client
      osu-lazer # circles gaem
      dex # .config/autostart helper for WMs
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
