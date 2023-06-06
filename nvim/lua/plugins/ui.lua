return {
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      --  local logo = [[
      -- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      -- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
      -- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      -- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
      -- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      -- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      --
      --                  [ @markasena ]
      --  ]]
      local logo = [[
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⢠⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡄⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣶⣿⠛⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠛⣿⣶⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣴⣶⣿⡿⣟⣽⡏⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⢹⣯⣻⢿⣿⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⡿⢟⣫⣵⣾⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣮⣝⡻⢿⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⣿⣿⣿⡿⢛⣡⣶⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣶⣌⡛⢿⣿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⡿⢋⣴⣿⣿⣿⡿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢍⣧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⢿⣿⣿⣿⣦⡙⢿⣿⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⡿⢋⣴⣿⣿⣿⡿⣫⣾⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⢍⣿⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣷⣝⢿⣿⣿⣿⣦⡙⢿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⠟⡋⣿⠟⣡⣾⣿⣿⣿⣫⣾⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⢿⢍⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣷⣝⣿⣿⣿⣷⣌⠻⣿⢙⠻⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡿⠟⢻⣿⡿⢋⣼⢣⢋⣴⣿⣿⣿⢟⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣠⣄⣀⡀⢀⣀⠀⣠⣴⠿⣏⣼⣯⣿⣧⣹⠿⣦⣄⠀⣀⡀⢀⣀⣠⣄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⡻⣿⣿⣿⣦⡙⡞⣧⡙⢿⣿⡟⠻⢿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⣫⡴⣡⣿⡿⢡⣿⡟⣡⣾⣿⣿⣿⣫⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣽⣻⠿⣿⣿⣿⣿⣾⡿⠎⣸⡿⣿⣿⢛⣇⠹⢿⣿⣿⣿⣿⣿⠿⣟⣯⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣝⣿⣿⣿⣷⣌⢻⣿⡌⢿⣿⣌⢦⣝⢿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⣴⡿⢋⣴⡿⣱⣿⡿⢡⣿⣿⣴⣿⣿⣿⡿⣱⣿⣿⣿⣿⣿⣿⠟⢿⣿⣿⣿⠻⢿⣿⣿⣿⣿⣾⣷⡹⣿⡎⣧⣿⣿⣽⣯⣿⣿⣼⡹⣿⢋⣾⣷⣿⣿⣿⣿⡿⠟⣿⣿⣿⡿⠻⣿⣿⣿⣿⣿⣿⣎⢿⣿⣿⣿⣦⣿⣿⡌⢿⣿⣎⢿⣦⡙⢿⣦⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⢀⣾⠟⢠⣿⣿⢱⣿⣿⢁⣾⡿⠿⢿⣿⣿⡟⠔⠉⠛⣿⣿⣿⠏⠀⠀⠀⢺⣿⠃⠀⠀⢻⣿⠛⠿⣿⣿⣿⣌⢹⣝⡮⡙⣻⣟⢋⢕⣫⡏⣡⣿⣿⣿⠿⠛⣿⡟⠀⠀⠘⣿⡗⠀⠀⠀⠹⣿⣿⣿⠛⠉⠢⢻⣿⣿⡿⠿⢟⣷⡈⣿⣿⡎⣿⣿⡄⠻⣷⡀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⣠⡿⠁⢀⣿⣿⢇⣿⣿⠇⠜⠁⠀⠀⣼⣿⡟⠀⠀⠀⠈⣿⡿⠃⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀⢿⠀⠀⠙⣿⡟⠻⢠⢻⣿⡮⢻⡟⣵⣿⡟⡄⠟⢻⣿⠋⠀⠀⡿⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠘⢿⣿⠁⠀⠀⠀⢻⣿⣧⠀⠀⠈⠣⠸⣿⣿⡸⣿⣿⡀⠈⢿⣄⠀⠀⠀⠀
  ⠀⠀⠀⣰⠏⠀⢀⣾⣿⣿⢠⣿⡟⠀⠀⠀⠀⠀⣿⡟⠀⠀⠀⠀⠀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃ ⣿⣷⣭⣿⡩⡩⣳⣭⣾⣿ ⠘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⠀⠀⠀⠀⠀⢻⣿⠀⠀⠀⠀⠀⢻⣿⡄⣿⣿⣷⡀⠀⠹⣆⠀⠀⠀
  ⠀⠀⡰⠃⠀⠀⣼⣿⡿⠃⢸⣿⠃⠀⠀⠀⠀⢸⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⡟⠿⣫⣿⣿⣿⣿⣿⣯⡟⠿⢻ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡇⠀⠀⠀⠀⠘⣿⡇⠘⢿⣿⣧⠀⠀⠘⢆⠀⠀
  ⠀⠔⠀⠀⠀⢰⣿⠟⠀⠀⢸⣿⠀⠀⠀⠀⠀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣯⡛⣿⡿⣫⣾⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⠀⠀⠀⠀⠀⣿⡇⠀⠀⠻⣿⡆⠀⠀⠀⠢⠀
  ⠀⠀⠀⠀⢀⣿⠉⠀⠀⠀⢸⣿⠀⠀⠀⠀⢰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⣿⡇⣿⡆⠻⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⣿⡇⠀⠀⠀⠉⣿⡀⠀⠀⠀⠀
  ⠀⠀⠀⠀⣸⠏⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣞⠀⣿⡇⠰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠀⠀⠀⣿⠁⠀⠀⠀⠀⠹⣇⠀⠀⠀⠀
  ⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠋⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⢿⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                                                Artifex
  ]]
      opts.section.header.val = vim.split(logo, "\n", { triempty = true })
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3500,
      background_colour = "#000000",
      level = vim.log.levels.WARN, -- help vim.log.levels
      render = "minimal",
      stages = "static",
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  -- COLOR SCHEME REGION
  {
    "catppuccin/nvim",
    -- lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        alpha = true,
        cmp = true,
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
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  --bufferline and lualine customization
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = require("lazyvim.config").icons
      local Util = require("lazyvim.util")

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = {
                left = 1, right = 0 }
            },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
            -- stylua: ignore
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
            },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = Util.fg("Statement"),
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = Util.fg("Constant"),
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = Util.fg("Debug"),
            },
            { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = Util.fg("Special") },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            "hostname"
            -- function()
            -- return " " .. os.date("%R")
            -- return vim.g.hostname()
            -- end,
          },
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      animate = {
        enabled = false
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
        { ft = "qf",         title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        { ft = "spectre_panel", size = { height = 0.4 } },
      },
      left = {}
    },
  }

}
