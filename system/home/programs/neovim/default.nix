{ pkgs, ... }:

{
  programs.lazyvim = {
    enable = true;

    installCoreDependencies = true;

    extras = {
      lang.nix = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
      lang.python = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
    };

    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];

    plugins = {
      colorscheme = ''
        return {
          { "ellisonleao/gruvbox.nvim" },

          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = "gruvbox",
            },
          },
        }  
      '';
    };
  };
}
