local Util = require("lazyvim.util")

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>fR", Util.telescope("resume"), desc = "Resume" },
    },
    opts = {
      pickers = {
        find_files = {
          follow = true,
        },
      },
      mappings = {
        i = {
          ["<c-t>"] = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
          end,
          ["<a-t>"] = function(...)
            return require("trouble.providers.telescope").open_selected_with_trouble(...)
          end,
          ["<a-i>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            Util.telescope("find_files", { no_ignore = true, default_text = line })()
          end,
          ["<a-h>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            Util.telescope("find_files", { hidden = true, default_text = line })()
          end,
          ["<C-Down>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-Up>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
          ["<C-f>"] = function(...)
            return require("telescope.actions").preview_scrolling_down(...)
          end,
          ["<C-b>"] = function(...)
            return require("telescope.actions").preview_scrolling_up(...)
          end,
        },
        n = {
          ["q"] = function(...)
            return require("telescope.actions").close(...)
          end,
        },
      },
    },
    -- opts = function(_, opts)
    --   table.insert(opts.pickers, find_files = { follow = true})
    -- end,
  },
  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>sB",
        ":Telescope file_browser file_browser path=%:p:h=%:p:h<cr>",
        desc = "Browse Files",
      },
    },
    config = function(_, opts)
      print(vim.inspect(opts))
      require("telescope").load_extension("file_browser")
    end,
  },


  --- NEO TREE SECTION DISABLED BY DEFAULT CHECK OIL
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    enabled = false,
    opts = {
      -- source_selector = {
      --   winbar = true,
      --   statusline = true,
      --   sources = {
      --     { source = "filesystem" },
      --     { source = "git_status" },
      --   },
      -- },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = true,
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_gitignored = true,
          hide_dotfiles = false,
          never_show = {
            ".vscode",
            ".git",
          },
        },
      },
      commands = {
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if (node.type == "directory" or node:has_children()) and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" or node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else                           -- if expanded and has children, seleect the next child
              require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
            end
          else -- if not a directory just open it
            state.commands.open(state)
          end
        end,
      },
      window = {
        -- position = "float",
        -- width = 30,
        mappings = {
          ["<space>"] = "none",
          o = "open",
          h = "parent_or_close",
          l = "child_or_open",
        },
      },
    },
  },
}
