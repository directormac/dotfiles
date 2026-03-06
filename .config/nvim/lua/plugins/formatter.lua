return {
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
      },
    },
  },
}
