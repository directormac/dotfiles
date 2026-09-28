-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  {
    'wakatime/vim-wakatime',
    setup = true,
  },
  -- add gruvbox
  { 'ellisonleao/gruvbox.nvim' },

  -- Configure LazyVim to load gruvbox
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'gruvbox',
    },
  },

  -- change trouble config
  {
    'folke/trouble.nvim',
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  { 'folke/trouble.nvim', enabled = false },

  -- add symbols-outline
  {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    keys = { { '<leader>cs', '<cmd>SymbolsOutline<cr>', desc = 'Symbols Outline' } },
    config = true,
  },
  -- override nvim-cmp and add cmp-emoji
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-emoji' },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require('cmp')
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = 'emoji' } }))
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = { prompt_position = 'top' },
        sorting_strategy = 'ascending',
        winblend = 0,
      },
    },
  },

  -- add telescope-fzf-native
  {
    'telescope.nvim',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function() require('telescope').load_extension('fzf') end,
    },
  },

  -- add pyright to lspconfig
  {
    'neovim/nvim-lspconfig',
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
      },
    },
  },

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'jose-elias-alvarez/typescript.nvim',
      init = function()
        require('lazyvim.util').on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set('n', '<leader>cR', 'TypescriptRenameFile', { desc = 'Rename File', buffer = buffer })
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
          require('typescript').setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = 'lazyvim.plugins.extras.lang.typescript' },

  -- add more treesitter parsers
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'bash',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'kotlin',
        'tsx',
        'typescript',
        'vim',
        'yaml',
      },
    },
  },

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        'tsx',
        'typescript',
      })
    end,
  },

  -- the opts function can also be used to change the default opts:
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function(_, opts) table.insert(opts.sections.lualine_x, '😄') end,
  },

  -- or you can return new options to override all the defaults
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function()
      return {
        --[[add your custom lualine config here]]
      }
    end,
  },

  -- use mini.starter instead of alpha
  { import = 'lazyvim.plugins.extras.ui.mini-starter' },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = 'lazyvim.plugins.extras.lang.json' },

  -- add any tools you want to have installed below
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'shellcheck',
        'shfmt',
        'flake8',
      },
    },
  },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    'L3MON4D3/LuaSnip',
    keys = function() return {} end,
  },
  -- then: setup supertab in cmp
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-emoji',
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      local luasnip = require('luasnip')
      local cmp = require('cmp')

      opts.mapping = vim.tbl_extend('force', opts.mapping, {
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        elixirls = {
          -- This forces the LSP to use the root LazyVim picked
          root_dir = function(fname) return require('lspconfig.util').root_pattern('mix.exs')(fname) end,
        },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- biome = {
        --   -- Force Biome to use UTF-16 to match ESLint/Svelte and stop the warning
        --   capabilities = {
        --     offsetEncoding = { "utf-16" },
        --   },
        --   -- ONLY run if biome.json is in the CURRENT folder or immediate parent
        --   -- This prevents the root Biome from "stealing" files in the Phoenix app
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
        --   end,
        --   single_file_support = false,
        -- },
        --
        -- eslint = {
        --   settings = {
        --     -- IMPORTANT: Disable ESLint as a formatter so it doesn't fight Biome
        --     format = false,
        --     workingDirectories = { mode = "auto" },
        --   },
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern("eslint.config.js", ".eslintrc.js", "package.json")(fname)
        --   end,
        -- },
        -- eslint = {
        --   settings = {
        --     -- This is the modern way to handle this in the eslint-lsp
        --     workingDirectories = { mode = "auto" },
        --   },
        --   -- Explicitly tell it NOT to run if no config is found
        --   on_new_config = function(config, new_root_dir)
        --     config.settings.rulesCustomizations = config.settings.rulesCustomizations or {}
        --     -- If no eslint config is found in the root, disable the server for this instance
        --     local util = require("lspconfig.util")
        --     local found_config = util.root_pattern(".eslintrc", ".eslintrc.js", "eslint.config.js")(new_root_dir)
        --     if not found_config then
        --       config.enabled = false
        --     end
        --   end,
        -- },
        -- biome = {
        --   single_file_support = false,
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
        --   end,
        -- },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    opts = {
      servers = {
        lua_ls = {},
        svelte = {},
        nil_ls = {},
        elixirls = {},
        vtsls = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')

      -- 1. Get the capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      capabilities.offsetEncoding = { 'utf-16' }

      for server, server_opts in pairs(opts.servers) do
        -- Skip special keys that aren't actually LSP servers
        if server == 'setup' or server == '*' or server == 'mason' then goto continue end

        -- Check if the server configuration exists in lspconfig
        local server_cfg = lspconfig[server]

        if server_cfg and type(server_cfg.setup) == 'function' then
          -- Merge capabilities
          server_opts.capabilities = vim.tbl_deep_extend('force', capabilities, server_opts.capabilities or {})

          -- Finally, run the setup
          server_cfg.setup(server_opts)
        else
          -- This helps you debug which "server" is causing the ghost error
          vim.notify('LSP Config: Skipping ' .. tostring(server), vim.log.levels.DEBUG)
        end

        ::continue::
      end
    end,
  },

  {
    'xiyaowong/telescope-emoji.nvim',
    keys = {
      {
        '<leader>.t',
        '<cmd>Telescope emoji<cr>',
        { desc = 'Find all emojis' },
      },
    },
    event = 'VeryLazy',
    dependencies = 'nvim-telescope/telescope.nvim',
    config = function(_, opts) require('telescope').load_extension('emoji') end,
  },
  {
    'ojroques/nvim-osc52', -- OSC52 Copy to system clipboard
    opts = {
      max_length = 0, -- Maximum length of selection (0 for no limit)
      silent = true, -- Disable message on successful copy
      trim = true, -- Trim surrounding whitespaces before copy
    },
  },
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>cs', '<cmd>AerialToggle!<CR>', { desc = 'Toggle Symbols(aerial)' } },
    },
    opts = {
      backends = { 'treesitter', 'lsp', 'markdown', 'man' },
    },
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    'nvim-neorg/neorg',
    build = ':Neorg sync-parsers',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('neorg').setup({
        load = {
          ['core.defaults'] = {}, -- Loads default behaviour
          ['core.concealer'] = {}, -- Adds pretty icons to your documents
          -- ["core.export.markdown"] = {
          --   extension = "md markdown",
          -- },
          -- ["core.completion"] = {},
          ['core.dirman'] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                default = '~/notes/neorg',
                personal = '~/notes/neorg/personal',
                work = '~/notes/neorg/work',
                dev = '~/notes/neorg/dev',
              },
            },
          },
        },
      })
    end,
  },
  {
    'Exafunction/codeium.vim',
    event = 'BufEnter',
    config = function()
      vim.g.codeium_disable_bindings = 1
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true })
      vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
      vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    event = 'VeryLazy',
    opts = function(_, opts)
      local started = false
      local function status()
        if not package.loaded['cmp'] then return end
        for _, s in ipairs(require('cmp').core.sources) do
          if s.name == 'codeium' then
            if s.source:is_available() then
              started = true
            else
              return started and 'error' or nil
            end
            if s.status == s.SourceStatus.FETCHING then return 'pending' end
            return 'ok'
          end
        end
      end

      local Util = require('lazyvim.util')
      local colors = {
        ok = Util.fg('Special'),
        error = Util.fg('DiagnosticError'),
        pending = Util.fg('DiagnosticWarn'),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function() return require('lazyvim.config').icons.kinds.Codeium end,
        cond = function() return status() ~= nil end,
        color = function() return colors[status()] or colors.ok end,
      })
    end,
  },
  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = {
      left = {
        {
          title = 'Neo-Tree',
          ft = 'neo-tree',
          filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
          pinned = true,
          open = function() vim.api.nvim_input('<esc><space>e') end,
          size = { height = 0.5 },
        },
        {
          ft = 'aerial',
          title = 'Symbols',
          size = { width = 0.3 },
          pinned = true,
          open = 'AerialToggle!',
        },
        { title = 'Neotest Summary', ft = 'neotest-summary' },
        -- {
        --   title = "Neo-Tree Git",
        --   ft = "neo-tree",
        --   filter = function(buf)
        --     return vim.b[buf].neo_tree_source == "git_status"
        --   end,
        --   pinned = true,
        --   open = "Neotree position=right git_status",
        -- },
        -- {
        --   title = "Neo-Tree Buffers",
        --   ft = "neo-tree",
        --   filter = function(buf)
        --     return vim.b[buf].neo_tree_source == "buffers"
        --   end,
        --   pinned = true,
        --   open = "Neotree position=top buffers",
        -- },
      },
      bottom = {
        {
          title = 'Grug Far',
          ft = 'grug-far',
        },
      },
    },
  },
  {
    'kevinhwang91/nvim-ufo', -- Better folds in Neovim
    event = 'VeryLazy',
    dependencies = 'kevinhwang91/promise-async',
    keys = {
      -- end, { desc = "Peek folds" })
      -- { "zR", require("ufo").openAllFolds(), { desc = "Open all folds" } },
      -- { "zM", require("ufo").closeAllFolds(), { desc = "Close all folds" } },
      -- { "zr", require("ufo").openFoldsExceptKinds(), { desc = "Generate function docs" } },
      -- { "zm", require("ufo").closeFoldsWith(), { desc = "Generate function docs" } },
      -- { "zv", require("ufo").peekFoldedLinesUnderCursor(), { desc = "Generate function docs" } },
    },
    opts = {
      preview = {
        win_config = {
          border = { '', '─', '', '', '', '─', '', '' },
          winhighlight = 'Normal:Folded',
          winblend = 0,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },
      fold_virt_text_handler = require('config.util').fold_virtual_text,
      close_fold_kinds_for_ft = {
        -- default = { "imports", "comment", "class", "functions" },
        -- c = { "comment", "region" },
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    event = 'VeryLazy',
    -- keys = {
    --   { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "File Diff Viewer" } },
    --   { "<leader>gf", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff" } },
    -- },
    -- config = function()
    --   local wk = require("which-key")
    --   wk.register({
    --     ["<leader>g"] = {
    --       f = { ":DiffviewFileHistory %<cr>", "File Diff Viewer" },
    --       v = { ":DiffviewOpen<cr>", "Git Diff" },
    --     },
    --   })
    --   require("diffview").setup()
    -- end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    keys = {
      {
        '<leader>fB',
        '<cmd>Telescope file_browser previewer=false hidden=true<cr>',
        { desc = 'Browse Files in root directory' },
      },
      {
        '<leader>fb',
        '<cmd>Telescope file_browser path=%:p:h select_buffer=true previewer=false hidden=true<cr>',
        { desc = 'Browse Files in root directory' },
      },
    },
    event = 'VeryLazy',
    dependencies = 'nvim-telescope/telescope.nvim',
    config = function(_, opts) require('telescope').load_extension('file_browser') end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    conf = vim.fn.executable('make') == 1,
    event = 'VeryLazy',
    dependencies = 'nvim-telescope/telescope.nvim',
    config = function(_, opts) require('telescope').load_extension('fzf') end,
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader><space>', '<cmd>Telescope find_files previewer=false hidden=true<cr>', desc = 'Find Files (cwd)' },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob',
          '!**/.git/*',
          '--glob',
          '!**/**-lock.yaml',
          '--glob',
          '!**/lazy-lock.json',
          '--glob',
          '!**/dist/*',
          '--glob',
          '!**/build/*',
          '--glob',
          '!**/.svelte-kit/*',
          '--glob',
          '!**/.nuxt/*',
          '--glob',
          '!**/.turbo/*',
          '--glob',
          '!**/.tsup/*',
          '--glob',
          '!**/.next/*',
          '--glob',
          '!**/.target/*',
          '--glob',
          '!**/test-results/*',
          '--glob',
          '!**/.yarn/*',
          '--glob',
          '!**/playwright-report/*',
          '--glob',
          '!**/.gradle/*',
          '-L',
        },
        -- NOTE: Add Ignore Patterns here
        file_ignore_patterns = {
          '.git/', -- ignore git files
          'node_modules/', -- ignore node_modules
          'tmp/', -- tmp folders ignore
          'build/', -- Build Folders
          './dist/', -- Dist Folders
          '.svelte-kit/', -- Svelte kit
          '.nuxt/', -- Svelte kit
          '.target/', -- Rust Target
          '.next/', -- Next Ignore
          '.turbo/', -- Next Ignore
          '.tsup/', -- Next Ignore
          '.vitepress/cache/*', -- Vitepress Cache Ignore
          '**/**-lock.yaml',
          '**/lazy-lock.json',
          '**/.yarn',
          '**/test-results/',
          '**/playwright-report/',
          '**/.gradle/',
          '**/.gradle/',
        },
      },
      pickers = {
        find_files = {
          find_command = {
            'rg',
            '--files',
            '--hidden',
            '--glob',
            '!**/.git/*',
            '--glob',
            '!**/**-lock.yaml',
            '--glob',
            '!**/lazy-lock.json',
            '--glob',
            '!**/dist/*',
            '--glob',
            '!**/build/*',
            '--glob',
            '!**/.svelte-kit/*',
            '--glob',
            '!**/.nuxt/*',
            '--glob',
            '!**/.turbo/*',
            '--glob',
            '!**/.tsup/*',
            '--glob',
            '!**/.next/*',
            '--glob',
            '!**/.target/*',
            '--glob',
            '!**/test-results/*',
            '--glob',
            '!**/.yarn/*',
            '--glob',
            '!**/playwright-report/*',
            '--glob',
            '!**/.gradle/*',
            '-L',
          },
        },
      },
    },
  },
}
