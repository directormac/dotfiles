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
  -- {
  --   "hardhackerlabs/theme-vim",
  --   name = "hardhacker",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.hardhacker_hide_tilde = 1
  --     vim.g.hardhacker_keyword_italic = 1
  --     vim.g.hardhacker_transparent_background = true
  --     -- custom highlights
  --     vim.g.hardhacker_custom_highlights = {}
  --     vim.cmd("colorscheme hardhacker")
  --   end,
  -- },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
