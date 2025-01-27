local unused = {
  {
    "xiyaowong/telescope-emoji.nvim",
    keys = {
      {
        "<leader>.t",
        "<cmd>Telescope emoji<cr>",
        { desc = "Find all emojis" },
      },
    },
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("emoji")
    end,
  },
  {
    "ojroques/nvim-osc52", -- OSC52 Copy to system clipboard
    opts = {
      max_length = 0, -- Maximum length of selection (0 for no limit)
      silent = true, -- Disable message on successful copy
      trim = true, -- Trim surrounding whitespaces before copy
    },
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>cs", "<cmd>AerialToggle!<CR>", { desc = "Toggle Symbols(aerial)" } },
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
    },
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          -- ["core.export.markdown"] = {
          --   extension = "md markdown",
          -- },
          -- ["core.completion"] = {},
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                default = "~/notes/neorg",
                personal = "~/notes/neorg/personal",
                work = "~/notes/neorg/work",
                dev = "~/notes/neorg/dev",
              },
            },
          },
        },
      })
    end,
  },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      vim.g.codeium_disable_bindings = 1
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<C-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true })
      vim.keymap.set("i", "<c-;>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true })
      vim.keymap.set("i", "<c-,>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true })
      vim.keymap.set("i", "<c-x>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local started = false
      local function status()
        if not package.loaded["cmp"] then
          return
        end
        for _, s in ipairs(require("cmp").core.sources) do
          if s.name == "codeium" then
            if s.source:is_available() then
              started = true
            else
              return started and "error" or nil
            end
            if s.status == s.SourceStatus.FETCHING then
              return "pending"
            end
            return "ok"
          end
        end
      end

      local Util = require("lazyvim.util")
      local colors = {
        ok = Util.fg("Special"),
        error = Util.fg("DiagnosticError"),
        pending = Util.fg("DiagnosticWarn"),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          return require("lazyvim.config").icons.kinds.Codeium
        end,
        cond = function()
          return status() ~= nil
        end,
        color = function()
          return colors[status()] or colors.ok
        end,
      })
    end,
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      left = {
        {
          title = "Neo-Tree",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          pinned = true,
          open = function()
            vim.api.nvim_input("<esc><space>e")
          end,
          size = { height = 0.5 },
        },
        {
          ft = "aerial",
          title = "Symbols",
          size = { width = 0.3 },
          pinned = true,
          open = "AerialToggle!",
        },
        { title = "Neotest Summary", ft = "neotest-summary" },
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
          title = "Grug Far",
          ft = "grug-far",
        },
      },
    },
  },
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    event = "VeryLazy",
    dependencies = "kevinhwang91/promise-async",
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
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      fold_virt_text_handler = require("config.util").fold_virtual_text,
      close_fold_kinds_for_ft = {
        -- default = { "imports", "comment", "class", "functions" },
        -- c = { "comment", "region" },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
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
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>fB",
        "<cmd>Telescope file_browser previewer=false hidden=true<cr>",
        { desc = "Browse Files in root directory" },
      },
      {
        "<leader>fb",
        "<cmd>Telescope file_browser path=%:p:h select_buffer=true previewer=false hidden=true<cr>",
        { desc = "Browse Files in root directory" },
      },
    },
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("file_browser")
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    conf = vim.fn.executable("make") == 1,
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("telescope").load_extension("fzf")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files previewer=false hidden=true<cr>", desc = "Find Files (cwd)" },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob",
          "!**/.git/*",
          "--glob",
          "!**/**-lock.yaml",
          "--glob",
          "!**/lazy-lock.json",
          "--glob",
          "!**/dist/*",
          "--glob",
          "!**/build/*",
          "--glob",
          "!**/.svelte-kit/*",
          "--glob",
          "!**/.nuxt/*",
          "--glob",
          "!**/.turbo/*",
          "--glob",
          "!**/.tsup/*",
          "--glob",
          "!**/.next/*",
          "--glob",
          "!**/.target/*",
          "--glob",
          "!**/test-results/*",
          "--glob",
          "!**/.yarn/*",
          "--glob",
          "!**/playwright-report/*",
          "--glob",
          "!**/.gradle/*",
          "-L",
        },
        -- NOTE: Add Ignore Patterns here
        file_ignore_patterns = {
          ".git/", -- ignore git files
          "node_modules/", -- ignore node_modules
          "tmp/", -- tmp folders ignore
          "build/", -- Build Folders
          "./dist/", -- Dist Folders
          ".svelte-kit/", -- Svelte kit
          ".nuxt/", -- Svelte kit
          ".target/", -- Rust Target
          ".next/", -- Next Ignore
          ".turbo/", -- Next Ignore
          ".tsup/", -- Next Ignore
          ".vitepress/cache/*", -- Vitepress Cache Ignore
          "**/**-lock.yaml",
          "**/lazy-lock.json",
          "**/.yarn",
          "**/test-results/",
          "**/playwright-report/",
          "**/.gradle/",
          "**/.gradle/",
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!**/**-lock.yaml",
            "--glob",
            "!**/lazy-lock.json",
            "--glob",
            "!**/dist/*",
            "--glob",
            "!**/build/*",
            "--glob",
            "!**/.svelte-kit/*",
            "--glob",
            "!**/.nuxt/*",
            "--glob",
            "!**/.turbo/*",
            "--glob",
            "!**/.tsup/*",
            "--glob",
            "!**/.next/*",
            "--glob",
            "!**/.target/*",
            "--glob",
            "!**/test-results/*",
            "--glob",
            "!**/.yarn/*",
            "--glob",
            "!**/playwright-report/*",
            "--glob",
            "!**/.gradle/*",
            "-L",
          },
        },
      },
    },
  },
}

return {}
