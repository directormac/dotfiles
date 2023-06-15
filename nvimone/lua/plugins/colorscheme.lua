return {
  {
    "catppuccin/nvim",
    -- lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      color_overrides = {
        all = {
          base = "#11111B",
          mantle = "#11111B",
        },
        mocha = {
          base = "#11111B",
          mantle = "#11111B",
          -- crust = "#11111B",
        },
      },
      -- transparent_background = true,
      show_end_of_buffer = false, -- show the '~' characters after the end of buffers
      term_colors = true,
      integrations = {
        alpha = true,
        cmp = true,
        bufferline = true,
        gitsigns = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true },
        neotest = true,
        noice = true,
        notify = true,
        nvimtree = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
      custom_highlights = function(C)
        return {
          -- For base configs
          -- NormalFloat = { fg = C.text, bg = C.none },
          -- FloatBorder = {
          --   fg = C.none,
          --   bg = C.none,
          -- },
          CursorLineNr = { fg = C.green },
          CursorLine = { bg = C.surface0 },
          LineNr = { fg = C.overlay1 },
          BufferLineBufferSelected = { bold = true, italic = false },
          BufferLineFill = { fg = C.mantle, bg = C.base },
          BufferLineNumbers = { fg = C.green, bg = C.crust },
          BufferLineNumbersSelected = { fg = C.green, bg = C.crust },
          BufferLineNumbersVisible = { fg = C.green, bg = C.crust },

          -- Bufferline Tab
          BufferLineTab = { bg = C.blue, fg = C.crust },
          BufferLineTabClose = { bg = C.base, fg = C.blue },
          BufferLineTabSelected = { bg = C.peach, fg = C.crust },
          BufferLineTabSeparator = { bg = C.blue, fg = C.base },
          BufferLineTabSeparatorSelected = { bg = C.peach, fg = C.base },
        }
      end,
    },
  },
}
