local Util = require("lazyvim.util")

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>fR", Util.telescope("resume"), desc = "Resume" },
    },
    opts = {
      pickers = {
        find_files = {
          follow = true,
        },
      },
    },
    -- opts = function(_, opts)
    --   table.insert(opts.pickers, find_files = { follow = true})
    -- end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>sB",
        ":Telescope file_browser file_browser path=%:p:h=%:p:h<cr>",
        desc = "Browse Files",
      },
    },
    config = function(_, opts)
      print(vim.inspect(opts))
      require("telescope").load_extension("file_browser")
    end,
  },
}
