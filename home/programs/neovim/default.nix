{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    neovide

    # lsp servers
    lua-language-server # lua
    nodePackages.typescript-language-server # ts/js
    vscode-langservers-extracted # html, css, js
    tailwindcss-language-server # tailwind
    vue-language-server # vue
    rust-analyzer # rust
    gopls # go
    clang-tools # clang
    basedpyright # python
    nil # nix
    yaml-language-server # yaml

    # formatters
    stylua # lua
    prettierd # web
    black # python
    isort # python improrts
    nixfmt-rfc-style # nix
    shfmt # shell

    gcc
    gnumake
    cmake
    nodejs
    ripgrep
    fd
  ];
}
