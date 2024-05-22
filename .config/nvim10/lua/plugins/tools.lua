return {
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>fo",
        "<cmd>Oil<cr>",
        { desc = "Oil explorer on current buffer directory" },
      },
      {
        "<leader>fO",
        "<cmd>Oil .<cr>",
        { desc = "Oil explorer on current buffer directory" },
      },
    },
    event = "VeryLazy",
    opts = {
      -- default_file_explorer = true,
      columns = {
        "icon",
        "size",
        -- "mtime",
      },
      -- Skip the confirmation popup for simple operations
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["q"] = "actions.close",
        ["<C-s>"] = "actions.save",
      },
      view_options = {
        show_hidden = true,
      },
    },
  },
}
