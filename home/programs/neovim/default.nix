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
      vim.opt.shortmess:append("I")

      vim.cmd[[highlight EndOfBuffer guifg=#d7d9e1 guibg=NONE]]
      vim.cmd[[highlight Normal guibg=NONE guibg=NONE]]
      vim.cmd[[highlight NormalNC guibg=NONE guibg=NONE]]

      require('nvim-autopairs').setup()

      require('lualine').setup{
        options = {
          icons_enabled = true,
          theme = 'auto',
        },
        sections = {
          lualine_a = { 'mode' },       -- режим теперь в статуслайне
          lualine_b = { 'branch' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }

      local cmp = require'cmp'
      cmp.setup{
        sources = { { name = 'buffer' } },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
      }
      EOF
    '';
  };
}
