return {
  {
    "ojroques/nvim-osc52", -- OSC52 Copy to system clipboard
    opts = {
      max_length = 0, -- Maximum length of selection (0 for no limit)
      silent = true, -- Disable message on successful copy
      trim = true, -- Trim surrounding whitespaces before copy
    },
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>cs", "<cmd>AerialToggle!<CR>", desc = { "Toggle Symbols(aerial)" } },
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
    },
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    event = "VeryLazy",
    dependencies = "kevinhwang91/promise-async",
    keys = {},
    opts = {
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      ---@diagnostic disable-next-line: assign-type-mismatch
      close_fold_kinds = { "imports", "comment" },
      ---@diagnostic disable-next-line: unused-local
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
  },
  {
    "m4xshen/hardtime.nvim", --hardtime practice
    event = "VeryLazy",
    dependencies = "neovim/nvim-lspconfig",
    lazy = true,
    -- opts = {},
    opts = {
      max_time = 1000,
      max_count = 2,
      disable_mouse = true,
      hint = true,
      allow_different_key = false,
      --stylua: ignore
      resetting_keys = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "c", "C", "x", "X",  "p", "P", },
      restricted_keys = { "h", "l", "-", "+", "gj", "gk" },
      hint_keys = { "k", "j", "^", "$", "a", "i", "c", "l" },
      disabled_keys = { "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" },
      disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason" },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("file_browser")
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    conf = vim.fn.executable("make") == 1,
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("fzf")
    end,
  },
}
