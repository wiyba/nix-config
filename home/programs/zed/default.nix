{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      theme = "Gruvbox Dark";
    };
  };
  home.packages = with pkgs; [
    neovide

    # lsp servers
    lua-language-server # lua
    typescript-language-server # ts/js
    vscode-langservers-extracted # html, css, js
    tailwindcss-language-server # tailwind
    vue-language-server # vue
    rust-analyzer # rust
    gopls # go
    clang-tools # clang
    basedpyright # python
    nil # nix
    nixd
    yaml-language-server # yaml

    # formatters
    stylua # lua
    prettierd # web
    black # python
    isort # python improrts
    nixfmt # nix
    shfmt # shell

    gcc
    gnumake
    cmake
    nodejs
    ripgrep
    fd
  ];
}
