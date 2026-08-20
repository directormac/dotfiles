return {
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     LazyVim.extend(opts.servers.tsgo, "settings.vtsls.tsserver.globalPlugins", {
  --       {
  --         name = "typescript-svelte-plugin",
  --         location = LazyVim.get_pkg_path("svelte-language-server", "/node_modules/typescript-svelte-plugin"),
  --         enableForWorkspaceTypeScriptVersions = true,
  --       },
  --     })
  --   end,
  -- },

  -- {
  --   "conform.nvim",
  --   opts = function(_, opts)
  --     if LazyVim.has_extra("formatting.prettier") then
  --       opts.formatters_by_ft = opts.formatters_by_ft or {}
  --       opts.formatters_by_ft.svelte = { "prettier" }
  --     end
  --   end,
  -- },
}
