return {
  {
    --"williamboman/mason.nvim",
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local registry = require("mason-registry")
      registry.refresh(function()
        local packages = registry.get_all_packages()
      end)

      table.insert(opts.ensure_installed, "ansible-language-server")
      table.insert(opts.ensure_installed, "ansible-lint")
      table.insert(opts.ensure_installed, "astro-language-server")
      table.insert(opts.ensure_installed, "biome")
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
      table.insert(opts.ensure_installed, "emmet-ls")
      table.insert(opts.ensure_installed, "eslint-lsp")
      -- table.insert(opts.ensure_installed, "elixir-ls")
      table.insert(opts.ensure_installed, "expert")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "gofumpt")
      table.insert(opts.ensure_installed, "goimports")
      table.insert(opts.ensure_installed, "gopls")
      table.insert(opts.ensure_installed, "graphql-language-service-cli")
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
      table.insert(opts.ensure_installed, "lua-language-server")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "mdx-analyzer")
      -- table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "ruff")
      -- table.insert(opts.ensure_installed, "ruff-lsp")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "taplo")
      -- table.insert(opts.ensure_installed, "svelte")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "vtsls")
      -- table.insert(opts.ensure_installed, "unocss-language-server")
      -- table.insert(opts.ensure_installed, "prisma-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
    end,
  },
  {
    "folke/neoconf.nvim",
    -- Remove 'cmd', let it load automatically so it can hook into LSP
    lazy = false,
    priority = 900, -- Ensure it loads before most other things
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- lua_ls = {},
        -- jsonls = {},
        expert = {
          settings = {
            workspaceSymbos = {
              minQueryLength = 0,
            },
          },
        },
        -- elixirls = {},
      },
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
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       svelte = {
  --         -- Prevents the Svelte LSP from fighting with Prettier
  --         enable_ts_plugin = true,
  --       },
  --       eslint = {
  --         settings = {
  --           -- Tell ESLint to only fix on save, not format
  --           workingDirectories = { mode = "auto" },
  --         },
  --       },
  --       vtsls = {},
  --     },
  --     setup = {
  --       -- This logic disables formatting for specific LSPs
  --       -- so Conform/Prettier can take over exclusively
  --       eslint = function()
  --         vim.api.nvim_create_autocmd("BufWritePre", {
  --           callback = function(event)
  --             if require("lazyvim.util").format.enabled() then
  --               -- Use EslintFixAll instead of formatting
  --               vim.cmd("EslintFixAll")
  --             end
  --           end,
  --         })
  --       end,
  --     },
  --   },
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       elixirls = {
  --         -- This forces the LSP to use the root LazyVim picked
  --         root_dir = function(fname)
  --           return require("lspconfig.util").root_pattern("mix.exs")(fname)
  --         end,
  --       },
  --     },
  --   },
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       -- biome = {
  --       --   -- Force Biome to use UTF-16 to match ESLint/Svelte and stop the warning
  --       --   capabilities = {
  --       --     offsetEncoding = { "utf-16" },
  --       --   },
  --       --   -- ONLY run if biome.json is in the CURRENT folder or immediate parent
  --       --   -- This prevents the root Biome from "stealing" files in the Phoenix app
  --       --   root_dir = function(fname)
  --       --     return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
  --       --   end,
  --       --   single_file_support = false,
  --       -- },
  --       --
  --       -- eslint = {
  --       --   settings = {
  --       --     -- IMPORTANT: Disable ESLint as a formatter so it doesn't fight Biome
  --       --     format = false,
  --       --     workingDirectories = { mode = "auto" },
  --       --   },
  --       --   root_dir = function(fname)
  --       --     return require("lspconfig.util").root_pattern("eslint.config.js", ".eslintrc.js", "package.json")(fname)
  --       --   end,
  --       -- },
  --       -- eslint = {
  --       --   settings = {
  --       --     -- This is the modern way to handle this in the eslint-lsp
  --       --     workingDirectories = { mode = "auto" },
  --       --   },
  --       --   -- Explicitly tell it NOT to run if no config is found
  --       --   on_new_config = function(config, new_root_dir)
  --       --     config.settings.rulesCustomizations = config.settings.rulesCustomizations or {}
  --       --     -- If no eslint config is found in the root, disable the server for this instance
  --       --     local util = require("lspconfig.util")
  --       --     local found_config = util.root_pattern(".eslintrc", ".eslintrc.js", "eslint.config.js")(new_root_dir)
  --       --     if not found_config then
  --       --       config.enabled = false
  --       --     end
  --       --   end,
  --       -- },
  --       -- biome = {
  --       --   single_file_support = false,
  --       --   root_dir = function(fname)
  --       --     return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
  --       --   end,
  --       -- },
  --     },
  --   },
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = { "saghen/blink.cmp" },
  --   opts = {
  --     servers = {
  --       lua_ls = {},
  --       svelte = {},
  --       nil_ls = {},
  --       elixirls = {},
  --       vtsls = {
  --         -- explicitly add default filetypes, so that we can extend
  --         -- them in related extras
  --         filetypes = {
  --           "javascript",
  --           "javascriptreact",
  --           "javascript.jsx",
  --           "typescript",
  --           "typescriptreact",
  --           "typescript.tsx",
  --         },
  --         settings = {
  --           complete_function_calls = true,
  --           vtsls = {
  --             enableMoveToFileCodeAction = true,
  --             autoUseWorkspaceTsdk = true,
  --             experimental = {
  --               maxInlayHintLength = 30,
  --               completion = {
  --                 enableServerSideFuzzyMatch = true,
  --               },
  --             },
  --           },
  --           typescript = {
  --             updateImportsOnFileMove = { enabled = "always" },
  --             suggest = {
  --               completeFunctionCalls = true,
  --             },
  --             inlayHints = {
  --               enumMemberValues = { enabled = true },
  --               functionLikeReturnTypes = { enabled = true },
  --               parameterNames = { enabled = "literals" },
  --               parameterTypes = { enabled = true },
  --               propertyDeclarationTypes = { enabled = true },
  --               variableTypes = { enabled = false },
  --             },
  --           },
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     local lspconfig = require("lspconfig")
  --
  --     -- 1. Get the capabilities from blink.cmp
  --     local capabilities = require("blink.cmp").get_lsp_capabilities()
  --     capabilities.offsetEncoding = { "utf-16" }
  --
  --     for server, server_opts in pairs(opts.servers) do
  --       -- Skip special keys that aren't actually LSP servers
  --       if server == "setup" or server == "*" or server == "mason" then
  --         goto continue
  --       end
  --
  --       -- Check if the server configuration exists in lspconfig
  --       local server_cfg = lspconfig[server]
  --
  --       if server_cfg and type(server_cfg.setup) == "function" then
  --         -- Merge capabilities
  --         server_opts.capabilities = vim.tbl_deep_extend("force", capabilities, server_opts.capabilities or {})
  --
  --         -- Finally, run the setup
  --         server_cfg.setup(server_opts)
  --       else
  --         -- This helps you debug which "server" is causing the ghost error
  --         vim.notify("LSP Config: Skipping " .. tostring(server), vim.log.levels.DEBUG)
  --       end
  --
  --       ::continue::
  --     end
  --   end,
  -- },
  {
    "windwp/nvim-ts-autotag",
    opts = {
      aliases = {
        ["heex"] = "html",
      },
    },
  },
}
