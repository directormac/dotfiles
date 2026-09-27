return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    ---@type CatppuccinOptions
    opts = {
      -- terminal_colors = true,
      falvour = 'mocha',
      background = { -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = true, -- disables setting the background color.
      float = {
        transparent = true, -- enable transparent floating windows
        solid = false, -- use solid styling for floating windows, see |winborder|
      },
      term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
      auto_integrations = true,
    },
  },
  {
    'folke/tokyonight.nvim',
    opts = {
      transparent = true,
      terminal_colors = true,
      style = 'night',
      light_style = 'night',
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    },
  },
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'catppuccin',
      -- colorscheme = 'tokyonight',
    },
  },
}
