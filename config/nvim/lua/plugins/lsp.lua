return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ansible-language-server",
        "ansible-lint",
        "alejandra",
        "astro-language-server",
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
        -- "tsgo",
        "oxfmt",
        "oxlint",
        "svelte-language-server",
        "vue-language-server",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      servers = {
        -- Note: vtsls and tsserver are managed by LazyVim extras.
        -- Explicitly disabling vtsls here with `vtsls = { enabled = false }`
        -- was causing the Vue extra to crash because it expected vtsls to be
        -- configured with filetypes.
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
        },
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
        qmlls = {
          cmd = { "qmlls6" },
          filetypes = { "qml", "qmljs" },
          root_markers = { ".git" },
        },
        nil_ls = {
          settings = {
            formatting = {
              command = { "alejandra" },
            },
            nix = {
              -- The heap memory limit in MiB for `nix` evaluation. // Currently it only applies to flake evaluation when `autoEvalInputs` is
              -- enabled, and only works for Linux. Other `nix` invocations may be also
              -- applied in the future. `null` means no limit.
              -- As a reference, `nix flake show --legacy nixpkgs` usually requires
              -- about 2GiB memory.
              -- Type: number | null
              -- Example: 1024
              maxMemory = 4086,

              flake = {
                -- Auto-archiving behavior which may use network.
                -- Ask every time.
                -- flake archive` when necessary.
                -- : Do not archive. Only load inputs that are already on disk.
                -- null | boolean
                -- true
                autoArchive = true,
                -- // Whether to auto-eval flake inputs.
                -- // The evaluation result is used to improve completion, but may cost
                -- // lots of time and/or memory.
                -- //
                -- // Type: boolean
                -- // Example: true
                autoEvalInputs = true,
                -- // The input name of nixpkgs for NixOS options evaluation.
                -- //
                -- // The options hierarchy is used to improve completion, but may cost
                -- // lots of time and/or memory.
                -- // If this value is `null` or is not found in the workspace flake's
                -- // inputs, NixOS options are not evaluated.
                -- //
                -- // Type: null | string
                -- // Example: "nixos"
                nixpkgsInputName = "nixpkgs",
              },
            },
          },
        },
        -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md#configuration-overview
        nixd = {
          cmd = { "nixd" },
          settings = {
            nixpkgs = {
              expr = 'import "${flake.inputs.nixpkgs}" { }',
              -- For flake.
              -- expr = 'import (builtins.getFlake "/home/artifex/.dotfiles").inputs.nixpkgs { }   ',
              --   This expression will be interpreted as "nixpkgs" toplevel
              --   Nixd provides package, lib completion/information from it.
              --   Resource Usage: Entries are lazily evaluated, entire nixpkgs takes 200~300MB for just "names".
              --   Package documentation, versions, are evaluated by-need.
              -- expr = "import <nixpkgs> { }",
              -- expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
            },
            formatting = {
              command = { "alejandra" },
            },
            -- Tell the language server your desired option set, for completion
            --  This is lazily evaluated.
            options = {
              nixos = {
                expr = '(let pkgs = import "${inputs.nixpkgs}" { }; in (pkgs.lib.evalModules { modules =  (import "${inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options',
                --  Map of eval information
                --  By default, this entriy will be read from `import <nixpkgs> { }`
                --  You can write arbitary nix expression here, to produce valid "options" declaration result.
                -- *NOTE*: Replace "<name>" below with your actual configuration name.
                --  If you're unsure what to use, you can verify with `nix repl` by evaluating
                --  the expression directly.
                -- expr = "let flake = builtins.getFlake(toString ./.); in flake.nixosConfigurations.vmachine.options",
              },
              -- Before configuring Home Manager options, consider your setup:
              -- Which command do you use for home-manager switching?
              --
              -- A. home-manager switch --flake .#... (standalone Home Manager)
              -- B. nixos-rebuild switch --flake .#... (NixOS with integrated Home Manager)
              --
              -- Configuration examples for both approaches are shown below.

              home_manager = {
                expr = '(let pkgs = import "${inputs.nixpkgs}" { }; lib = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib; in (lib.evalModules { modules =  (import "${inputs.home-manager}/modules/modules.nix") { inherit lib pkgs; check = false; }; })).options',
                -- A:
                -- expr: "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.artifex.options"

                -- B:
                -- expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.artifex.options.home-manager.users.type.getSubOptions []",

                -- expr = "let flake = builtins.getFlake(toString ./.); in flake.homeConfigurations.artifex@vmachine.options",
              },
            },
          },
        },
      },
      inlay_hints = { enabled = false },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
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
}
