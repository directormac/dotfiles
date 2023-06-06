return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "codelldb")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "rustfmt")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
      table.insert(opts.ensure_installed, "prettierd")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "css-lsp")
      table.insert(opts.ensure_installed, "eslint-lsp")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "astro-language-server")
      table.insert(opts.ensure_installed, "zls")
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
      table.insert(opts.ensure_installed, "html")
      table.insert(opts.ensure_installed, "javascript")
      table.insert(opts.ensure_installed, "css")
      table.insert(opts.ensure_installed, "json")
      table.insert(opts.ensure_installed, "typescript")
      table.insert(opts.ensure_installed, "svelte")
      table.insert(opts.ensure_installed, "vue")
      table.insert(opts.ensure_installed, "tsx")
      table.insert(opts.ensure_installed, "rust")
      table.insert(opts.ensure_installed, "markdown")
      table.insert(opts.ensure_installed, "markdown_inline")
      table.insert(opts.ensure_installed, "toml")
      table.insert(opts.ensure_installed, "lua")
    end,
  },
}
