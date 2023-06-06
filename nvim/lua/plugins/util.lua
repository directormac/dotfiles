-- vim.o.showcmdloc = "statusline"
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

return {
  {
    "stevearc/oil.nvim",
    opts = {
      use_default_keymaps = false,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "none",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
        ["q"] = {
          callback = function()
            require("oil").close()
          end,
        },
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },


}
