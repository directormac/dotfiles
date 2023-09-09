return {
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
      { "<leader>gd", "<cmd>Neogen<CR>", { desc = "Generate function docs" } },
    },
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
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
      { "<leader>cs", "<cmd>AerialToggle!<CR>", { desc = "Toggle Symbols(aerial)" } },
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
      fold_virt_text_handler = require("config.util").fold_virtual_text,
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
    keys = {
      { "<leader>uh", "<cmd>Hardtime toggle<cr>", { desc = "Toggle Hardtime" } },
    },
    dependencies = "neovim/nvim-lspconfig",
    vscode = true,
    opts = {
      max_time = 1000,
      max_count = 4,
      resetting_keys = {
        ["1"] = { "n", "v" },
        ["2"] = { "n", "v" },
        ["3"] = { "n", "v" },
        ["4"] = { "n", "v" },
        ["5"] = { "n", "v" },
        ["6"] = { "n", "v" },
        ["7"] = { "n", "v" },
        ["8"] = { "n", "v" },
        ["9"] = { "n", "v" },
        ["c"] = { "n" },
        ["C"] = { "n" },
        ["d"] = { "n" },
        -- ["x"] = { "n" },
        ["X"] = { "n" },
        ["y"] = { "n" },
        ["Y"] = { "n" },
        ["p"] = { "n" },
        ["P"] = { "n" },
      },
      disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason", "oil" },
    },
  },
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
      columns = {
        "icon",
        "size",
        "mtime",
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
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>g"] = {
          f = { ":DiffviewFileHistory %<cr>", "File Diff Viewer" },
          v = { ":DiffviewOpen<cr>", "Git Diff" },
        },
      })
      require("diffview").setup()
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>fB",
        "<cmd>Telescope file_browser file_browser previewer=false hidden=true<cr>",
        { desc = "Browse Files in root directory" },
      },
    },
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
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- vimgrep_arguments = {
        --   "rg",
        --   "-uu",
        --   "--files",
        --   "--hidden",
        -- },
        -- NOTE: Add Ignore Patterns here
        file_ignore_patterns = {
          ".git/", -- ignore git files
          "node_modules/", -- ignore node_modules
          "tmp/", -- tmp folders ignore
          "build/", -- Build Folders
          "dist/", -- Dist Folders
          ".svelte-kit/", -- Svelte kit
          ".next/", -- Next Ignore
        },
      },
      -- pickers = {
      --   find_command = {
      --     "rg",
      --     "-uu",
      --     "--files",
      --     "--hidden",
      --     "-g",
      --     "!.git/",
      --     "!node_modules",
      --     "!tmp/",
      --     "!build/",
      --     "!dist/",
      --     "!.svelte-kit/", -- Svelte kit
      --     "!.next/", -- Next Ignore
      --     "-L",
      --   },
      -- },
    },
  },
  {
    "ziontee113/color-picker.nvim",
    keys = {
      {
        "<leader>fc ",
        "<cmd>PickColor<cr>",
        { desc = "Color Picker" },
      },
      {
        "<leader>fcc",
        "<cmd>PickColorInsert<cr>",
        { desc = "HTML Color Picker" },
      },
      {
        "<leader>fcx",
        "<cmd>ConvertHEXandRGB<cr>",
        { desc = "Convert Hex and RGB" },
      },
      {
        "<leader>fcv",
        "<cmd>ConvertHEXandHSL<cr>",
        { desc = "Convert Hex and HSL" },
      },
    },
    config = function()
      require("color-picker")
    end,
  },
  {
    "ziontee113/icon-picker.nvim",
    keys = {
      {
        "<leader>fh",
        "<cmd>IconPickerInsert html_colors<cr>",
        { desc = "HTML Color Picker" },
      },
      {
        "<leader>.",
        "<cmd>IconPickerInsert emoji symbols html_colors nerd_font_v3 nerd_font<cr>",
        { desc = "Icon Picker" },
      },
    },
    config = function()
      require("icon-picker").setup({
        disable_legacy_commands = true,
      })
    end,
  },
}
