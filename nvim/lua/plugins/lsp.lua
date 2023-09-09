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
      table.insert(opts.ensure_installed, "kotlin-debug-adapter")
      table.insert(opts.ensure_installed, "ktlint")
      table.insert(opts.ensure_installed, "kotlin-language-server")
      table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "js-debug-adapter")
      table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "prettierd")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "taplo")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "prisma-language-server")
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
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "prisma",
          "svelte",
          "tsx",
          "typescript",
          "vue",
        })
      end
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
}
