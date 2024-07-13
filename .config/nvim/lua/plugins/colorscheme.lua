return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
      falvour = "mocha",
      color_overrides = {
        all = {
          base = "#11111B",
          mantle = "#11111B",
        },
      },
    },
    show_end_of_buffer = false,
    term_colors = true,
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      style = "storm",
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
