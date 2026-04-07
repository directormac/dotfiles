return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ansible-language-server",
        "ansible-lint",
        "astro-language-server",
        "biome",
        "clang-format",
        "clangd",
        "cmakelang",
        "cmakelint",
        "codelldb",
        "cpplint",
        "cpptools",
        "css-lsp",
        "debugpy",
        "delve",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-ls",
        "eslint-lsp",
        "expert",
        "eslint_d",
        "gofumpt",
        "goimports",
        "gopls",
        "graphql-language-service-cli",
        "hadolint",
        "helm-ls",
        "html-lsp",
        "java-debug-adapter",
        "java-test",
        "jdtls",
        "js-debug-adapter",
        "json-lsp",
        "kotlin-debug-adapter",
        "ktlint",
        "kotlin-language-server",
        "lua-language-server",
        "mdx-analyzer",
        "ruff",
        "rust-analyzer",
        "taplo",
        "tsgo",
        "svelte-language-server",
        "vue-language-server",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Note: vtsls and tsserver are managed by LazyVim extras.
        -- Explicitly disabling vtsls here with `vtsls = { enabled = false }`
        -- was causing the Vue extra to crash because it expected vtsls to be
        -- configured with filetypes.
        cssls = {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
        emmet_ls = {
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
                ["bem.enabled"] = true,
              },
            },
          },
        },
        expert = {
          settings = {
            workspaceSymbos = {
              minQueryLength = 0,
            },
          },
        },
      },
      inlay_hints = { enabled = false },
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
}
