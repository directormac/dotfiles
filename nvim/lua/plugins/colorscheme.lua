return {

  {
    "catppuccin/nvim",
    -- lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        notify = true,
        mini = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
