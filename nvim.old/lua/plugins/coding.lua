return {
  {
    "ojroques/nvim-osc52", -- OSC52 Copy to system clipboard
    opts = {
      max_length = -1, -- Maximum length of selection (0 for no limit)
      silent = false, -- Disable message on successful copy
      trim = false, -- Trim surrounding whitespaces before copy
    },
  },
  {
    "m4xshen/hardtime.nvim", --hardtime practice
    opts = {
      max_time = 1000,
      max_count = 2,
      disable_mouse = false,
      hint = true,
      allow_different_key = false,
      resetting_keys = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "c", "d" },
      restricted_keys = { "h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" },
      hint_keys = { "k", "j", "^", "$", "a", "x", "i", "d", "y", "c", "l" },
      disabled_keys = { "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" },
      disabled_filetypes = { "lazy", "mason" },
    },
  },
}
