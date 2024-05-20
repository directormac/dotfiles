return {
  -- {
  --   "folke/noice.nvim",
  --   opts = {
  --     notify = {
  --       enabled = false,
  --     },
  --   },
  -- },
  -- { "rcarriga/nvim-notify", enabled = false },
  -- {
  --   "luckasRanarison/tailwind-tools.nvim",
  --   opts = {}, -- your configuration
  -- },
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
      close_fold_kinds_for_ft = {
        default = { "imports", "comment", "class" },
      },
      -- ---@diagnostic disable-next-line: unused-local
      -- provider_selector = function(bufnr, filetype, buftype)
      --   return { "treesitter", "indent" }
      -- end,
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
        "<leader>..",
        "<cmd>IconPickerInsert emoji<cr>",
        { desc = "Emoji Picker" },
      },
      {
        "<leader>. ",
        "<cmd>IconPickerInsert emoji<cr>",
        { desc = "Emoji Picker" },
      },
      {
        "<leader>./",
        "<cmd>IconPickerInsert symbols nerd_font_v3<cr>",
        { desc = "Icon Picker - symbols and fonts" },
      },
    },
    config = function()
      require("icon-picker").setup({
        disable_legacy_commands = true,
      })
    end,
  },
  {
    "wakatime/vim-wakatime",
    setup = true,
  },
}
