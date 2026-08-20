return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
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
      color_overrides = {
        all = {
          -- base = "#11111B",
          -- mantle = "#11111B",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Comment = { fg = colors.flamingo },
          RenderMarkdownCode = { bg = colors.mantle },
        }
      end,
      term_colors = true,
      -- highlight_overrides = {
      --   all = function(colors)
      --     return {}
      --   end,
      -- },
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
