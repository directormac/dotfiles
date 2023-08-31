return {
  {
    "akinsho/bufferline.nvim",
    -- events = "VeryLazy",
    keys = {
        -- stylua: ignore
        { "<C-1>", function() require("bufferline").go_to(1, true) end, desc = "Go to first buffer", },
        -- stylua: ignore
        { "<C-2>", function() require("bufferline").go_to(2, true) end, desc = "Go to second buffer", },
        -- stylua: ignore
        { "<C-3>", function() require("bufferline").go_to(3, true) end, desc = "Go to third buffer", },
        -- stylua: ignore
        { "<C-4>", function() require("bufferline").go_to(4, true) end, desc = "Go to fourth buffer", },
        -- stylua: ignore
        { "<C-5>", function() require("bufferline").go_to(5, true) end, desc = "Go to fifth buffer", },
        -- stylua: ignore
        { "<C-6>", function() require("bufferline").go_to(6, true) end, desc = "Go to sixth buffer", },
    },
    opts = function(_, opts)
      opts.options = {
        indicator = { style = "none" },
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = "oil",
            text = "file explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      -- local icons = require("lazyvim.config").icons
      -- local Util = require("lazyvim.util")
      options = {
        -- fmt = string.lower,
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        icons_enabled = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function()
              return "  "
            end,
          },
        },
        lualine_b = {
          { "location", seperator = " ", padding = { left = 1, right = 0 } },
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "fileformat", separator = "", padding = { left = 0, right = 1 } },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              hint = " ",
              info = " ",
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          -- stylua: ignore
          {function() return require("noice").api.status.command.get() end, cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end, color = { fg = "#bb9af7"},},
          -- stylua: ignore
          {function() return require("noice").api.status.mode.get() end,cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,color = { fg = "#7aa2f7"},},
          -- stylua: ignore
          {function() return "  " .. require("dap").status() end, cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end, color = { fg = "#f7768e"},},
          {
            function()
              local icon = " "
              local status = require("copilot.api").status.data
              return icon .. (status.message or "")
            end,
            cond = function()
              local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot", bufnr = 0 })
              return ok and #clients > 0
            end,
            color = function()
              if not package.loaded["copilot"] then
                return
              end
              local status = require("copilot.api").status.data
              local colors = {
                [""] = { fg = "#7aa2f7" },
                ["Normal"] = { fg = "#7aa2f7" },
                ["Warning"] = { fg = "#f7768e" },
                ["InProgress"] = { fg = "#9ece6a" },
              }
              return colors[status.status] or colors[""]
            end,
          },
        },
        lualine_y = {
          {
            "diff",
            color = { bg = "#1d202f" },
            symbols = {
              added = " ",
              modified = " ",
              removed = " ",
            },
          },
          { "branch" },
        },
        lualine_z = {},
      },
      extensions = { "lazy" },
    },
  },
  {
    "tiagovla/scope.nvim",
    opts = {
      restore_state = true,
    },
    config = function(_, opts)
      require("telescope").load_extension("scope")
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
    "tzachar/highlight-undo.nvim",
    config = function()
      require("highlight-undo").setup()
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    opts = function(_, opts)
      local hi = require("mini.hipatterns")
      return {
        -- custom LazyVim option to enable the tailwind integration
        tailwind = {
          enabled = true,
          ft = {
            "typescriptreact",
            "javascriptreact",
            "css",
            "javascript",
            "typescript",
            "svelte",
            "html",
            "vue",
            "astro",
            "markdown",
          },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = "full",
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
        },
      }
    end,
  },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    component_separators = "",
    section_separators = "",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
   █████╗ ██████╗ ████████╗██╗███████╗███████╗██╗  ██╗
  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝╚██╗██╔╝
  ███████║██████╔╝   ██║   ██║█████╗  █████╗   ╚███╔╝
  ██╔══██║██╔══██╗   ██║   ██║██╔══╝  ██╔══╝   ██╔██╗
  ██║  ██║██║  ██║   ██║   ██║██║     ███████╗██╔╝╚██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
                         
  ]]
      dashboard.section.header.val = vim.split(logo, "\n", { triempty = true })
      dashboard.section.buttons.val = {
        -- dashboard.button(
        --   "b",
        --   " " .. " Browse files",
        --   ":Telescope file_browser file_browser follow=true previewer=false <CR>"
        -- ),
        dashboard.button("f", " " .. " Find file", ":Telescope find_files follow=true path_display=smart<CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        -- dashboard.button("g", " " .. " Find text", ":Telescope live_grep follow=true path_display=smart<CR>"),
        -- dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope frecency workspace=CWD <CR>"),
        dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("u", "   Update plugins", "<cmd>lua require('lazy').sync()<CR>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.buttons.opts = {
        spacing = 0,
      }
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
      }
      dashboard.config.opts = { margin = 5 }
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end
      require("alpha").setup(dashboard.opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms 🚀"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
