return {
  {
    "luckasRanarison/tailwind-tools.nvim",
    -- commit = "da8eee8a6ae62e99ffc30e0c9ab862cbdc76b3ed",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- keys = {
    --   { "<leader>ut", "<cmd>TailwindConcealToggle<CR>", { desc = "Toggle Tailwind Conceal" } },
    -- },
    opts = {
      document_color = {
        enabled = true, -- can be toggled by commands
        kind = "inline", -- "inline" | "foreground" | "background"
        inline_symbol = "󰝤 ", -- only used in inline mode
        debounce = 200, -- in milliseconds, only applied in insert mode
      },
      conceal = {
        enabled = true, -- can be toggled by commands
        min_length = 60, -- only conceal classes exceeding the provided length
        symbol = "󱏿", -- only a single character is allowed
        highlight = { -- extmark highlight options, see :h 'highlight'
          fg = "#38BDF8",
        },
      },
    }, -- your configuration
  },
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
  {
    "stevearc/oil.nvim",
    -- commit = "50c4bd4ee216f08907f64d0295c0663a69e58ffb",
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
  },
}
