-- lazydev.nvim: loads only the relevant definitions for a lua file,
-- and correlates the globals we create with our own files.
return {
  'lazydev.nvim',
  cmd = { 'LazyDev' },
  ft = 'lua',
  after = function(_)
    require('lazydev').setup({
      library = {
        {
          words = { 'lz%.n', 'nixInfo%.lzn' },
          path = nixInfo.get_nix_plugin_path('lz.n') .. '/lua',
        },
      },
    })
  end,
}
