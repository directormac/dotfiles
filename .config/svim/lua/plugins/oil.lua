-- return {
--     "stevearc/oil.nvim",
--     ---@module 'oil'
--     ---@type oil.SetupOpts
--     opts = {
--         view_options = {
--             show_hidden = true,
--         },
--         float = {
--             border = "single",
--         },
--     },
--     -- Optional dependencies
--     dependencies = { { "echasnovski/mini.icons", opts = {} } },
--     -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
--     -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
--     lazy = false,
-- }

return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    columns = {
      "icon",
      "size",
    },
    -- Skip the confirmation popup for simple operations
    skip_confirm_for_simple_edits = true,
    keymaps = {
      ["q"] = "actions.close",
      ["<C-s>"] = false,
    },
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    {
      "<leader>-",
      "<cmd>Oil<cr>",
      { desc = "Oil explorer on current buffer directory" },
    },
    {
      "<leader>=",
      "<cmd>Oil .<cr>",
      { desc = "Oil explorer on current buffer directory" },
    },
  },
}
