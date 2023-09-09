local unused = {
  {
    "xiyaowong/telescope-emoji.nvim",
    keys = {
      {
        "<leader>.t",
        "<cmd>Telescope emoji<cr>",
        { desc = "Find all emojis" },
      },
    },
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("emoji")
    end,
  },
}

return {}
