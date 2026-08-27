return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",                      desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>",           desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",                     desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",                      desc = "Delete Buffers to the Left" },
      { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",                      desc = "Prev Buffer" },
      { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",                      desc = "Next Buffer" },
      { "[b",         "<cmd>BufferLineCyclePrev<cr>",                      desc = "Prev Buffer" },
      { "]b",         "<cmd>BufferLineCycleNext<cr>",                      desc = "Next Buffer" },
      { "[B",         "<cmd>BufferLineMovePrev<cr>",                       desc = "Move buffer prev" },
      { "]B",         "<cmd>BufferLineMoveNext<cr>",                       desc = "Move buffer next" },
      { "<leader>bj", "<cmd>BufferLinePick<cr>",                           desc = "Pick Buffer" },
      { "<leader>bd", "<cmd>bwipeout<cr>",                                 desc = "Pick Buffer" },
      -- stylua: ignore
      { "<A-1>",      function() require("bufferline").go_to(1, true) end, desc = "Go to first buffer", },
      -- stylua: ignore
      { "<A-2>",      function() require("bufferline").go_to(2, true) end, desc = "Go to second buffer", },
      -- stylua: ignore
      { "<A-3>",      function() require("bufferline").go_to(3, true) end, desc = "Go to third buffer", },
      -- stylua: ignore
      { "<A-4>",      function() require("bufferline").go_to(4, true) end, desc = "Go to fourth buffer", },
      -- stylua: ignore
      { "<A-5>",      function() require("bufferline").go_to(5, true) end, desc = "Go to fifth buffer", },
      -- stylua: ignore
      { "<A-6>",      function() require("bufferline").go_to(6, true) end, desc = "Go to sixth buffer", },
    },
    opts = {
      options = {
        -- close_command = function(n) Snacks.bufdelete(n) end,
        -- right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
  {
    "echasnovski/mini.statusline",
    version = false,
    ---@type mini.statuslMiniStatusline.activeine
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      cmdline = {
        view = "cmdline",
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>sn",  "",                                                                            desc = "+noice" },
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                 mode = "c",                              desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                                   desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end,                                desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end,                                    desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end,                                desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end,                                   desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>",       function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  silent = true,                           expr = true,              desc = "Scroll Forward",  mode = { "i", "n", "s" } },
      { "<c-b>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true,                           expr = true,              desc = "Scroll Backward", mode = { "i", "n", "s" } },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },

  {
    "tiagovla/scope.nvim",
    opts = {
      restore_state = true,
    },
    config = function(_, opts)
      -- require("telescope").load_extension("scope")
      require("scope").setup(opts)
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "compact",
      timeout = 2000,
      background_colour = "#11111b",
      max_height = function()
        return math.floor(vim.o.lines * 0.50)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.50)
      end,
    },
  },
  {
    "folke/trouble.nvim",
    opts = {
      auto_preview = true,
      multitile = true,
      modes = {
        preview_float = {
          mode = "diagnostics",
          preview = {
            type = "float",
            relative = "editor",
            border = "rounded",
            title = "Preview",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.3, height = 0.3 },
            zindex = 200,
          },
        },
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
      keys = {
        ["go"] = {
          action = function(_, ctx)
            if not ctx.item then
              return
            end
            local diag = ctx.item
            if diag and diag.reference and diag.reference.url then
              local url = diag.reference.url
              if url and url ~= "" then
                vim.ui.open(url)
                return
              end
            end

            vim.notify("No reference URL found for this diagnostic.", vim.log.levels.WARN)
          end,
          desc = "Open Diagnostic URL in Browser",
        },
      },
    },
  },
}
