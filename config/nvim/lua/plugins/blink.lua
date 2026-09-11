return {
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.lib", "rafamadriz/friendly-snippets" }, -- Ensure it's marked as a dependency
    version = "*", -- Or your preferred version/branch
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
}
