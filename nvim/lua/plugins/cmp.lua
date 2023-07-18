return {
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    event = { "BufRead Cargo.toml" },
    dependencies = { "simrat39/rust-tools.nvim" },
    opts = {
      popup = {
        autofocus = true,
        hide_on_select = true,
      },
      -- null_ls = {
      --   enabled = true,
      --   name = "Crates",
      -- },
    },
    config = function(_, opts)
      local wk = require("which-key")
      local crates = require("crates")
      local util = require("config.util")
      wk.register({
        ["<leader>c"] = {
          k = { util.crates_popup, "Show crate popup" },
          c = {
            name = "+Crates",
            mode = "n",
            r = { crates.reload, "Reload Crates" },
            i = { crates.show_popup, "Crate Information" },
            v = { crates.show_versions_popup, "Crate Versions" },
            f = { crates.show_features_popup, "Crate Features" },
            d = { crates.show_dependencies_popup, "Crate Dependencies" },
            u = { crates.update_all_crates, "Update Crates" },
            g = { crates.upgrade_crates, "Upgrade Crates" },
          },
        },
      })
      crates.setup(opts)
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = { "saecki/crates.nvim" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "crates" } }))
    end,
  },
  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   opts = function(_, opts)
  --     table.insert(opts.sources, {})
  --   end,
  -- },
}
