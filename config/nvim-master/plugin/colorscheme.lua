-- [[ Colorscheme ]]
-- You can easily change to a different colorscheme.
-- Change the name of the colorscheme plugin below, and then
-- change the command under that to load whatever the name of that colorscheme is.
--
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.

-- vim.pack.add {  'https://github.com/folke/tokyonight.nvim' }
-- require('tokyonight').setup({
--   styles = {
--     comments = { italic = false }, -- Disable italics in comments
--   },
--   sidebars = 'transparent',
--   floats = 'transparent',
--   terminal_colors = true,
--   style = 'night',
--   light_style = 'night',
-- })

vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
})

-- reference https://github.com/catppuccin/nvim#configuration

require('catppuccin').setup({
  terminal_colors = true,
  falvour = 'mocha',
  background = { -- :h background
    light = 'latte',
    dark = 'mocha',
  },
  transparent_background = true,
  float = {
    transparent = true,
  },
  integrations = {
    blink_cmp = true,
    snacks = true,
  },
  -- auto_integrations = true,
})

vim.cmd.colorscheme('catppuccin')
