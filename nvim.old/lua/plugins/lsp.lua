return {
  {
    "neovim/nvim-lspconfig",
    cmd = {
      "LspInfo",
    },
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
      dependencies = {
        "b0o/SchemaStore.nvim",
        version = false, -- last release is way too old
      },
      "simrat39/rust-tools.nvim",
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        tailwindcss = {
          filetypes_exclude = { "markdown" },
        },
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
        rust_analyzer = {
          -- mason = false,
          -- cmd = { vim.fn.expand("~/.rustup/toolchains/stable-x86_64-pc-windows-msvc/bin/rust-analyzer.exe", nosuf?)}
        },
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        tailwindcss = function(_, opts)
          local tw = require("lspconfig.server_configurations.tailwindcss")
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, tw.default_config.filetypes)
        end,
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
        rust_analyzer = function(_, opts)
          require("rust-tools").setup({ server = opts })
          return true
        end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "astro-language-server")
      table.insert(opts.ensure_installed, "codelldb")
      table.insert(opts.ensure_installed, "css-lsp")
      table.insert(opts.ensure_installed, "eslint-lsp")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "js-debug-adapter")
      table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "prettierd")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "rustfmt")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
      -- table.insert(opts.ensure_installed, "zls")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "css")
      table.insert(opts.ensure_installed, "html")
      table.insert(opts.ensure_installed, "javascript")
      table.insert(opts.ensure_installed, "json")
      table.insert(opts.ensure_installed, "json5")
      table.insert(opts.ensure_installed, "jsonc")
      table.insert(opts.ensure_installed, "lua")
      table.insert(opts.ensure_installed, "markdown")
      table.insert(opts.ensure_installed, "markdown_inline")
      table.insert(opts.ensure_installed, "rust")
      table.insert(opts.ensure_installed, "svelte")
      table.insert(opts.ensure_installed, "toml")
      table.insert(opts.ensure_installed, "tsx")
      table.insert(opts.ensure_installed, "typescript")
      table.insert(opts.ensure_installed, "vue")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
      table.insert(opts.sources, nls.builtins.formatting.prettierd)
    end,
  },
}
