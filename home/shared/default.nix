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
    gh # cli for github
    jq # json parser
    kdePackages.dolphin # file manager
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
