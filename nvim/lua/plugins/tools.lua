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
    "m4xshen/hardtime.nvim", --hardtime practice
    opts = {
      max_time = 1000,
      max_count = 3,
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
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    event = "VeryLazy",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      require("ufo").setup({
        close_fold_kinds = { "imports", "comment" },
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      })
    end,
  },

  -- measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
  -- session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
  },
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },
  -- Sticky windows
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      -- stylua: ignore
      { "<leader>ue", function() require("edgy").toggle() end, desc = "Edgy toggle Window" },
       -- stylua: ignore
      { "<leader>uE", function() require("edgy").select() end, desc = "Edgy Select Window" },
    },
    left = {},
    opts = {
      animate = {
        enabled = false,
      },
      bottom = {
        -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
        { ft = "toggleterm", size = { height = 0.3 } },
        {
          ft = "lazyterm",
          title = "Terminal",
          size = { height = 0.3 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
        "Trouble",
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 0.3 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        { ft = "spectre_panel", size = { height = 0.4 } },
        {
          ft = "noice",
          -- size = { height = 0.4 },
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
      },
      left = {
        -- {
        --   ft = "oil",
        --   title = "Oil Explorer System",
        --   pinned = true,
        --   -- filter = function (buf)
        --   --   return vim.bo[buf].oil
        --   -- end
        --   open = function()
        --     require("oil").open(require("oil").get_current_dir())
        --   end,
        -- },
      },
      right = {
        { ft = "aerial", title = "Symbols", size = { width = 0.3 } },
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>o", "<cmd>AerialToggle!<CR>", desc = { "Toggle Symbols(aerial)" } },
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
}
