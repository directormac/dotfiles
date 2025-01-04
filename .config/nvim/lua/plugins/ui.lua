return {
  {
    "akinsho/bufferline.nvim",
    keys = {
        -- stylua: ignore
        { "<A-1>", function() require("bufferline").go_to(1, true) end, desc = "Go to first buffer", },
        -- stylua: ignore
        { "<A-2>", function() require("bufferline").go_to(2, true) end, desc = "Go to second buffer", },
        -- stylua: ignore
        { "<A-3>", function() require("bufferline").go_to(3, true) end, desc = "Go to third buffer", },
        -- stylua: ignore
        { "<A-4>", function() require("bufferline").go_to(4, true) end, desc = "Go to fourth buffer", },
        -- stylua: ignore
        { "<A-5>", function() require("bufferline").go_to(5, true) end, desc = "Go to fifth buffer", },
        -- stylua: ignore
        { "<A-6>", function() require("bufferline").go_to(6, true) end, desc = "Go to sixth buffer", },
    },
    opts = function(_, opts)
      opts.options = {
        indicator = { style = "none" },
        always_show_bufferline = true,
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = "oil",
            text = "file explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        icons_enabled = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function()
              -- return "  "
              return "  "
            end,
          },
        },
        lualine_b = {
          { "branch" },
        },
        lualine_z = {},
      },
      extensions = { "lazy" },
    },
  },
  {
    "tiagovla/scope.nvim",
    opts = {
      restore_state = true,
    },
    config = function(_, opts)
      require("telescope").load_extension("scope")
      require("scope").setup(opts)
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "compact",
      timeout = 2000,
      background_colour = "#11111b",
      max_height = function()
        return math.floor(vim.o.lines * 0.50)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.50)
      end,
    },
  },
  {
    "tzachar/highlight-undo.nvim",
    config = function()
      require("highlight-undo").setup()
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    opts = function(_, opts)
      local hi = require("mini.hipatterns")
      return {
        -- custom LazyVim option to enable the tailwind integration
        tailwind = {
          enabled = true,
          ft = {
            "typescriptreact",
            "javascriptreact",
            "css",
            "javascript",
            "typescript",
            "svelte",
            "html",
            "vue",
            "astro",
            "markdown",
          },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = "full",
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
        },
      }
    end,
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        header = [[

 █████╗ ██████╗ ████████╗██╗███████╗███████╗██╗  ██╗
██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝╚██╗██╔╝
███████║██████╔╝   ██║   ██║█████╗  █████╗   ╚███╔╝ 
██╔══██║██╔══██╗   ██║   ██║██╔══╝  ██╔══╝   ██╔██╗ 
██║  ██║██║  ██║   ██║   ██║██║     ███████╗██╔╝╚██╗
╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
ɔɐɯɹoʇɔǝɹᴉp
         

        ]],
      },
    },
  },
  {
    "m4xshen/hardtime.nvim",
    -- keys = {
    --   { "<leader>uH", "<cmd>Hardtime toggle<cr>", { desc = "Toggle Hardtime" } },
    -- },
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    -- vscode = true,
    opts = {
      disable_mouse = false,
      max_time = 1000,
      max_count = 3,
      resetting_keys = {
        ["1"] = { "n", "v" },
        ["2"] = { "n", "v" },
        ["3"] = { "n", "v" },
        ["4"] = { "n", "v" },
        ["5"] = { "n", "v" },
        ["6"] = { "n", "v" },
        ["7"] = { "n", "v" },
        ["8"] = { "n", "v" },
        ["9"] = { "n", "v" },
        ["c"] = { "n" },
        ["C"] = { "n" },
        ["d"] = { "n" },
        ["x"] = { "n" },
        ["X"] = { "n" },
        ["y"] = { "n" },
        ["Y"] = { "n" },
        ["p"] = { "n" },
        ["P"] = { "n" },
      },
      disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason", "oil" },
    },
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
          size = { height = 0.4 },
        },
        { title = "Neotest Summary", ft = "neotest-summary" },
        {
          ft = "toggleterm",
          size = { height = 0.4 },
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        {
          ft = "noice",
          size = { height = 0.4 },
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        {
          ft = "lazyterm",
          title = "LazyTerm",
          size = { height = 0.4 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
        "Trouble",
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- don't open help files in edgy that we're editing
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },
        { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
      },
    },
  },
}
