return {
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.lib", "rafamadriz/friendly-snippets" }, -- Ensure it's marked as a dependency
    version = "*", -- Or your preferred version/branch

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Your blink configuration here
    },
    build = function()
      require("blink.cmp").build():pwait()
    end,

    -- to your lazy.nvim config.
    -- Then re-run the build via
    --   :Lazy build blink.cmp  See
    --   :h blink-cmp-installation  for more information.
  },

  {
    "saghen/blink.cmp",
    -- ft = { "oil" },
    -- enabled = false,
    opts = {
      enabled = function()
        return vim.bo.filetype ~= "oil" and vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
      end,
    },
  },
}
