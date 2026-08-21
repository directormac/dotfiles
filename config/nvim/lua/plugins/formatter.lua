return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        caddy = {
          command = "caddy",
          args = { "fmt", "-" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        caddy = { "caddy" },
      },
    },
  },

  ------@param bufnr integer
  ------@param ... string
  ------@return string
  ---local function first(bufnr, ...)
  ---  local conform = require("conform")
  ---  for i = 1, select("#", ...) do
  ---    local formatter = select(i, ...)
  ---    if conform.get_formatter_info(formatter, bufnr).available then
  ---      return formatter
  ---    end
  ---  end
  ---  return select(1, ...)
  ---end
  ---
  ---require("conform").setup({
  ---  formatters_by_ft = {
  ---    markdown = function(bufnr)
  ---      return { first(bufnr, "prettierd", "prettier"), "injected" }
  ---    end,
  ---  },
  ---})
  {
    "stevearc/conform.nvim",
    -- optional = true,
    opts = {
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        zsh = { "shfmt" },
      },
    },
  },

  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   opts = {
  --     formatters = {},
  --     formatters_by_ft = {
  --       javascript = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       javascriptreact = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       typescript = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       typescriptreact = { "oxfmt", "biome", "prettier", stop_after_first = true },
  --       json = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       vue = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       svelte = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       astro = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --     },
  --   },
  -- },

  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters = {
  --       vp_fix = {
  --         condition = function()
  --           local local_binary = vim.fn.fnamemodify(vim.fn.getcwd() .. "/node_modules/.bin/vp", ":p")
  --           return (vim.uv or vim.loop).fs_stat(local_binary) ~= nil
  --         end,
  --         command = function()
  --           return vim.fn.fnamemodify(vim.fn.getcwd() .. "/node_modules/.bin/vp", ":p")
  --         end,
  --         args = { "lint", "--fix", "--", "$FILENAME" },
  --         stdin = false,
  --         exit_codes = { 0, 1 },
  --       },
  --     },
  --     formatters_by_ft = {
  --       -- Flat arrays. conform runs them sequentially if they are just listed.
  --       -- If you want biome/prettier to be fallbacks to oxfmt, you group them
  --       -- with stop_after_first = true inside a sub-table, but only for the formatters.
  --       javascript = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       javascriptreact = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       typescript = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       typescriptreact = { "vp_fix", "oxfmt", "biome", "prettier", stop_after_first = true },
  --       json = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       vue = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       svelte = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --       astro = { "vp_fix", "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true },
  --     },
  --   },
  -- },

  -- {
  --   "mfussenegger/nvim-lint",
  --   -- Event to trigger linters
  --   events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  --   opts = function(_, opts)
  --     local pattern = "::([^ ]+) file=(.*),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+),title=(.*)::(.*)"
  --     local severities = {
  --       ["error"] = vim.diagnostic.severity.ERROR,
  --       ["warning"] = vim.diagnostic.severity.WARN,
  --     }
  --     local groups = { "severity", "file", "lnum", "end_lnum", "col", "end_col", "code", "message" }
  --
  --     opts.linters.oxlint = {
  --       cmd = function()
  --         local local_binary = vim.fn.fnamemodify(vim.fn.getcwd() .. "/node_modules/.bin/vp", ":p")
  --         -- Use vim.uv for Neovim 0.10+, fallback to vim.loop for older versions
  --         return (vim.uv or vim.loop).fs_stat(local_binary) and local_binary or "vp"
  --       end,
  --       stdin = false,
  --       args = { "lint", "--", "--format", "github" },
  --       stream = "stdout",
  --       ignore_exitcode = true,
  --       parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "oxlint" }, {}),
  --     }
  --
  --     -- Safely append to existing linters_by_ft
  --     opts.linters_by_ft = opts.linters_by_ft or {}
  --     local filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro" }
  --
  --     for _, ft in ipairs(filetypes) do
  --       opts.linters_by_ft[ft] = { "oxlint", "biomejs", stop_after_first = true }
  --     end
  --   end,
  -- },

  -- {
  --   "stevearc/conform.nvim",
  --   -- optional = true,
  --   opts = function(_, opts)
  --     local supported = {
  --       "javascript",
  --       "javascriptreact",
  --       "typescript",
  --       "typescriptreact",
  --       "json",
  --       "vue",
  --       "svelte",
  --       "astro",
  --     }
  --
  --     local formatters = { "oxfmt", "biome", "prettier", "prettierd", stop_after_first = true }
  --
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, ft in ipairs(supported) do
  --       opts.formatters_by_ft[ft] = formatters
  --     end
  --
  --     -- The options you set here will be merged with the builtin formatters.
  --     -- You can also define any custom formatters here.
  --     ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
  --     opts.formatters = opts.formatters or {}
  --
  --
  --     local util = require("lspconfig.util")
  --     local fname = vim.api.nvim_buf_get_name(bufnr)
  --
  --     local oxc_markers = util.insert_package_json(
  --       { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" },
  --       { "oxfmt", "vite%-plus" },
  --       fname
  --     )
  --
  --     oxc_markers = util.root_markers_with_field(
  --       oxc_markers,
  --       { "vite.config.ts" },
  --       { "vite%-plus", "fmt:" },
  --       fname,
  --       "all"
  --     )
  --
  --     local biome_config_files = { "biome.json", "biome.jsonc" }
  --
  --     opts.formatters.biome = {
  --
  --     }
  --
  --   end,
  -- },

  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, ft in ipairs(supported) do
  --       opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
  --       table.insert(opts.formatters_by_ft[ft], "oxfmt")
  --     end
  --   end,
  -- },

  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, ft in ipairs(supported) do
  --       opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
  --       table.insert(opts.formatters_by_ft[ft], "oxfmt")
  --     end
  --   end,
  -- },
  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   ---@param opts ConformOpts
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, ft in ipairs(supported) do
  --       opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
  --       table.insert(opts.formatters_by_ft[ft], "prettier")
  --     end
  --
  --     opts.formatters = opts.formatters or {}
  --     opts.formatters.prettier = {
  --       condition = function(_, ctx)
  --         return M.has_parser(ctx) and (vim.g.lazyvim_prettier_needs_config ~= true or M.has_config(ctx))
  --       end,
  --     }
  --   end,
  -- },

  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   ---@param opts ConformOpts
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, ft in ipairs(supported) do
  --       opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
  --       table.insert(opts.formatters_by_ft[ft], "biome")
  --     end
  --
  --     opts.formatters = opts.formatters or {}
  --     opts.formatters.biome = {
  --       require_cwd = true,
  --     }
  --   end,
  -- },
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters_by_ft = {
  --       -- Use a list to run multiple, or a sub-list to pick the first available
  --       -- For Svelte, I highly recommend ONLY Prettier to avoid the semicolon bug
  --       svelte = { "prettier" },
  --       javascript = { "prettier", "eslint" },
  --       typescript = { "prettier", "eslint" },
  --     },
  --     formatters = {
  --       prettier = {
  --         -- This is redundant with your global option but good for safety
  --         condition = function(self, ctx)
  --           return vim.fs.find({ ".prettierrc", "prettier.config.js" }, { path = ctx.filename, upward = true })[1]
  --         end,
  --       },
  --       eslint = {
  --         condition = function(self, ctx)
  --           return vim.fs.find({ "eslint.config.js", ".eslintrc.js" }, { path = ctx.filename, upward = true })[1]
  --         end,
  --       },
  --       biome = {
  --         -- Only run biome if a config file is found walking up from the current file
  --         condition = function(self, ctx)
  --           return vim.fs.find({ "biome.json", "biome.jsonc", ".git" }, {
  --             path = ctx.filename,
  --             upward = true,
  --           })[1]
  --         end,
  --       },
  --     },
  --   },
  --  },
}
