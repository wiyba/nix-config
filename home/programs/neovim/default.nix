{ pkgs, ... }:

{
  programs.neovim = {
    enable        = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      nvim-autopairs
      vim-sleuth
      nvim-cmp
      cmp-buffer
      lualine-nvim
      nvim-web-devicons
    ];

    extraConfig = ''
      lua << EOF
      vim.o.showmode = false
      vim.opt.shortmess:append "I"

      require('nvim-autopairs').setup()

      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
        },
      }

      local cmp = require'cmp'
      cmp.setup {
        sources = { { name = 'buffer' } },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
      }
      EOF
    '';
  };
}