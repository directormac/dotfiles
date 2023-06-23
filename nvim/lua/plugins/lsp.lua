return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "astro-language-server")
      table.insert(opts.ensure_installed, "clang-format")
      table.insert(opts.ensure_installed, "clangd")
      table.insert(opts.ensure_installed, "cpplint")
      table.insert(opts.ensure_installed, "cpptools")
      table.insert(opts.ensure_installed, "codelldb")
      table.insert(opts.ensure_installed, "css-lsp")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "emmet-ls")
      table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "js-debug-adapter")
      table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "prettierd")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "taplo")
      table.insert(opts.ensure_installed, "rustfmt")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "prisma-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "astro")
      table.insert(opts.ensure_installed, "css")
      table.insert(opts.ensure_installed, "cpp")
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
      table.insert(opts.incremental_selection, { enable = false })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
      table.insert(opts.sources, nls.builtins.formatting.prettierd)
      table.insert(opts.sources, nls.builtins.code_actions.eslint_d)
      table.insert(opts.sources, nls.builtins.formatting.yamlfmt)
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    events = "VeryLazy",
    dependencies = "neovim/nvim-lspconfig",
    config = function()
      local rust_tools = require("rust-tools")
      local wk = require("which-key")
      rust_tools.setup({
        tools = {
          runnables = {
            use_telescope = true,
          },
          on_initialized = function()
            ---@diagnostic disable-next-line: missing-parameter
            require("notify").notify("Rust Tools Initialized", "info")
          end,
          hover_actions = {
            max_height = function()
              return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
              return math.floor(vim.o.columns * 0.75)
            end,
            auto_focus = true,
          },
        },
        server = {
          on_attach = function(_, bufnr)
            -- Override Code action on rust files
            wk.register({
              ["<leader>c"] = {
                h = { rust_tools.hover_actions.hover_actions, "Rust Tools Hover Actions", buffer = bufnr },
                a = { rust_tools.code_action_group.code_action_group, "Rust Tools Code Actions", buffer = bufnr },
              },
            })
          end,
          settings = {
            ["rust-analyzer"] = {
              -- enable clippy on save
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },
      })
    end,
  },
}
