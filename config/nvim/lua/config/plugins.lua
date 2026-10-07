-- The single entrypoint for lazy.nvim (lze).
--
-- Specs live in `lua/plugins/*.lua` and `lua/lsp/*.lua`; each one returns a list of
-- specs. They are pulled in with lze's `import` spec field, which `require`s the
-- module. That keeps them require-able (so `vim.loader` can cache the bytecode)
-- and keeps `auto_enable` / `for_cat` gating working per spec.
--
-- See https://github.com/BirdeeHub/lze?tab=readme-ov-file#structuring-your-plugins
nixInfo.lze.load({
  { import = 'plugins.colorscheme' },
  { import = 'plugins.snacks' },
  { import = 'plugins.oil' },
  { import = 'plugins.ui' },
  { import = 'plugins.completion' },
  { import = 'plugins.editing' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.lazydev' },
  { import = 'plugins.mason' },
  -- lsp
  { import = 'lsp' },
  { import = 'lsp.lua' },
  { import = 'lsp.nix' },
})
