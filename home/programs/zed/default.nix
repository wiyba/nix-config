{ pkgs, inputs, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = inputs.zed-editor.packages.${pkgs.stdenv.hostPlatform.system}.default;
    userSettings = {
      theme = "Gruvbox Dark";
      languages.Nix = {
        formatter.external = {
          command = "nixpkgs-fmt";
          arguments = [ ];
        };
      };
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
    nixpkgs-fmt # nix (less aggressive than nixfmt-rfc-style)
    shfmt # shell

    gcc
    gnumake
    cmake
    nodejs
    ripgrep
    fd
  ];
}
