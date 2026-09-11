return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    ---@type CatppuccinOptions
    opts = {
      falvour = "mocha",
      background = { -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      float = {
        transparent = true,
        -- solid = true,
      },
      auto_integrations = true,
      term_colors = true,
      color_overrides = {
        all = {
          -- base = "#11111B",
          -- mantle = "#11111B",
        },
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      terminal_colors = true,
      style = "night",
      light_style = "night",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
      -- colorscheme = "tokyonight",
    },
  },
}
