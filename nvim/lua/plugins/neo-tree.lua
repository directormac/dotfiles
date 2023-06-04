return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
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
            else -- if expanded and has children, seleect the next child
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
