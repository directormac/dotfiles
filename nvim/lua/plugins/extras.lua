if true then
  return {}
end

return {
  {
    "max397574/better-escape.nvim",
    lazy = true,
    opts = {
      mapping = { "jk", "jj" }, -- a table with mappings to use
      timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
      clear_empty_lines = false, -- clear line after escaping if there is only whitespace
      keys = "<Esc>", -- keys used for escaping, if it is a function will
    },
  },

  {
    "medwatt/tabulous",
    config = function()
      require("tabulous").setup({ sessions_path = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/") })
    end,
  },

  {
    "kdheepak/tabline.nvim",
    opts = {
      options = {
        enabled = true,
        show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
        show_devicons = true, -- this shows devicons in buffer section
        show_bufnr = false, -- this appends [bufnr] to buffer section,
        show_filename_only = true, -- shows base filename only instead of relative path in filename
        modified_icon = "+ ", -- change the default modified icon
        modified_italic = true, -- set to true by default; this determines whether the filename turns italic if modified
        show_tabs_only = false, -- this shows only tabs instead of tabs + buffers
      },
    },
    config = function(_, opts)
      require("tabline").setup(opts)
    end,
  },
  -- tab scopes?
  -- {
  -- 	"backdround/tabscope.nvim",
  -- 	config = function()
  -- 		require("tabscope").setup({})
  -- 	end,
  -- },
  {
    --   █████████████ █ 
    "nanozuki/tabby.nvim",
    config = function()
      local pallete = require("catppuccin.palettes").get_palette("mocha")
      local filename = require("tabby.filename")
      local util = require("tabby.util")
      local cwd = function()
        return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
      end
      local line = {
        hl = "TabLineFill",
        layout = "active_wins_at_tail",
        head = {
          { cwd, hl = "TabLineFill" },
          { "█", hl = "TabLineFill" },
        },
        active_tab = {
          label = function(tabid)
            return {
              " " .. tabid .. "",
              hl = "TabLineFill",
            }
          end,
          -- left_sep = { "|", hl = "TabLineFill" },
          right_sep = { "|", hl = "TabLineFill" },
        },
        inactive_tab = {
          label = function(tabid)
            return {
              "" .. tabid .. "",
              hl = "TabLineFill",
            }
          end,
          -- left_sep = { "|", hl = "TabLineFill" },
          right_sep = { "|", hl = "TabLineFill" },
        },
        top_win = {
          label = function(winid)
            return {
              "  " .. filename.unique(winid) .. " ",
              hl = "TabLineFill",
            }
          end,
          left_sep = { "|", hl = "TabLineFill" },
          -- right_sep = { "|", hl = "TabLineFill" },
        },
        win = {
          label = function(winid)
            return {
              "  " .. filename.unique(winid) .. " ",
              hl = "TabLine",
            }
          end,
          left_sep = { "|", hl = "TabLineFill" },
          -- right_sep = { "|", hl = "TabLineFill" },
        },
        tail = {
          { "|", hl = "TabLineFill" },
          { "  ", hl = "TabLineFill" },
        },
      }

      require("tabby").setup({
        tabline = line,
      })
    end,
  },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local Util = require("helpers.util")
      local colors = {
        [""] = Util.fg("Special"),
        ["Normal"] = Util.fg("Special"),
        ["Warning"] = Util.fg("DiagnosticError"),
        ["InProgress"] = Util.fg("DiagnosticWarn"),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local icon = require("lazyvim.config").icons.kinds.Copilot
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
          return colors[status.status] or colors[""]
        end,
      })
    end,
  },

  -- copilot cmp source
  {
    "nvim-cmp",
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        dependencies = "copilot.lua",
        opts = {},
        config = function(_, opts)
          local copilot_cmp = require("copilot_cmp")
          copilot_cmp.setup(opts)
          -- attach cmp source whenever copilot attaches
          -- fixes lazy-loading issues with the copilot cmp source
          require("lazyvim.util").on_attach(function(client)
            if client.name == "copilot" then
              copilot_cmp._on_insert_enter({})
            end
          end)
        end,
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      table.insert(opts.sources, 1, { name = "copilot", group_index = 2 })

      opts.sorting = {
        priority_weight = 2,
        comparators = {
          require("copilot_cmp.comparators").prioritize,

          -- Below is the default comparitor list and order for nvim-cmp
          cmp.config.compare.offset,
          -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }
    end,
  },
}
