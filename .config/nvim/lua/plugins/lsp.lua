return {

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "ansible-language-server")
      table.insert(opts.ensure_installed, "ansible-lint")
      table.insert(opts.ensure_installed, "astro-language-server")
      -- table.insert(opts.ensure_installed, "biome")
      table.insert(opts.ensure_installed, "clang-format")
      table.insert(opts.ensure_installed, "clangd")
      table.insert(opts.ensure_installed, "cmakelang")
      table.insert(opts.ensure_installed, "cmakelint")
      table.insert(opts.ensure_installed, "codelldb")
      table.insert(opts.ensure_installed, "cpplint")
      table.insert(opts.ensure_installed, "cpptools")
      table.insert(opts.ensure_installed, "css-lsp")
      table.insert(opts.ensure_installed, "debugpy")
      table.insert(opts.ensure_installed, "delve")
      -- table.insert(opts.ensure_installed, "deno")
      table.insert(opts.ensure_installed, "docker-compose-language-service")
      table.insert(opts.ensure_installed, "dockerfile-language-server")
      table.insert(opts.ensure_installed, "elixir-ls")
      table.insert(opts.ensure_installed, "emmet-ls")
      table.insert(opts.ensure_installed, "eslint-lsp")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "gofumpt")
      table.insert(opts.ensure_installed, "goimports")
      table.insert(opts.ensure_installed, "gopls")
      -- table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "hadolint")
      table.insert(opts.ensure_installed, "helm-ls")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "java-debug-adapter")
      table.insert(opts.ensure_installed, "java-test")
      table.insert(opts.ensure_installed, "jdtls")
      table.insert(opts.ensure_installed, "js-debug-adapter")
      table.insert(opts.ensure_installed, "json-lsp")
      table.insert(opts.ensure_installed, "kotlin-debug-adapter")
      table.insert(opts.ensure_installed, "ktlint")
      table.insert(opts.ensure_installed, "kotlin-language-server")
      table.insert(opts.ensure_installed, "html-lsp")
      -- table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "ruff")
      table.insert(opts.ensure_installed, "ruff-lsp")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "taplo")
      table.insert(opts.ensure_installed, "svelte-language-server")
      -- table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "vtsls")
      -- table.insert(opts.ensure_installed, "unocss-language-server")
      -- table.insert(opts.ensure_installed, "prisma-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "astro",
          "css",
          "cpp",
          "html",
          "gleam",
          "javascript",
          "json",
          "lua",
          -- "markdown",
          -- "markdown_inline",
          "prisma",
          "svelte",
          "java",
          "kotlin",
          "slint",
          "tsx",
          "typescript",
          "vue",
        })
      end
      table.insert(opts.incremental_selection, { enable = false })
      -- table.insert(opts.autotag, { enable = true })
    end,
  },
  {
    "nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
  {
    "nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig/configs")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      lspconfig.emmet_ls.setup({
        -- on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "svelte",
          "pug",
          "typescriptreact",
          "vue",
          "ex",
          "heex",
        },
        init_options = {
          html = {
            options = {
              -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
              ["bem.enabled"] = true,
            },
          },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gleam = {},
        -- biome = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      -- for language support
      -- @see https://biomejs.dev/internals/language-support/
      formatters_by_ft = {
        -- ["javascript"] = { "biome" },
        -- ["javascriptreact"] = { "biome" },
        -- ["typescript"] = { "biome" },
        -- ["typescriptreact"] = { "biome" },
        -- ["json"] = { "biome" },
        -- ["jsonc"] = { "biome" },
        -- ["svelte"] = { "biome" },
        -- ["astro"] = { "biome" },
        -- ["vue"] = { "biome" },
        -- ["css"] = { "biome" },
        -- ["scss"] = { "biome" },
        -- ["less"] = { "biome" },
        -- ["html"] = { "biome" },
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {
      aliases = {
        ["heex"] = "html",
      },
    },
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   commit = "7e348da6e5085ac447144a2ef4b637220ba27209",
  -- },
}
