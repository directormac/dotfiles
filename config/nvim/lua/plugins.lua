-- The single entrypoint for lze.
--
-- Specs live in `lua/plugins/*.lua` and `lua/lsp/*.lua`. The plugins directory is
-- discovered automatically with lzextras' `mod_dir_to_spec`, so a new file there is
-- imported without editing this one. The lsp files stay explicit: order matters
-- (shared nvim-lspconfig spec first, then the per-language trigger specs).
--
-- `import` uses `require()`, so these files get `vim.loader` bytecode caching for
-- free and `auto_enable` / `for_cat` gating keep working per spec.
--
-- See https://github.com/BirdeeHub/lze?tab=readme-ov-file#structuring-your-plugins
nixInfo.lze.load({
  { import = require('lzextras').mod_dir_to_spec('plugins') },
  -- lsp
  { import = 'lsp' },
  { import = 'lsp.lua' },
  { import = 'lsp.nix' },
})
