return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent = true,
      transparent_background = true,
      float = {
        transparent = true,
        solid = true,
      },
      falvour = "mocha",
      color_overrides = {
        all = {
          base = "#11111B",
          mantle = "#11111B",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Comment = { fg = colors.flamingo },
          RenderMarkdownCode = { bg = colors.mantle },
        }
      end,
      -- highlight_overrides = {
      --   all = function(colors)
      --     return {}
      --   end,
      -- },
    },

    -- show_end_of_buffer = false,
    term_colors = true,
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
      colorscheme = "catppuccin",
      -- colorscheme = "tokyonight",
    },
  },
}
