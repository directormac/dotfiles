-- lazydev.nvim: loads only the relevant definitions for a lua file,
-- and correlates the globals we create with our own files.
nixInfo.lze.load({
  {
    'lazydev.nvim',
    auto_enable = true,
    cmd = { 'LazyDev' },
    ft = 'lua',
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { 'nixInfo%.lze' }, path = nixInfo('lze', 'plugins', 'start', 'lze') .. '/lua' },
          {
            words = { 'nixInfo%.lze' },
            path = nixInfo('lzextras', 'plugins', 'start', 'lzextras') .. '/lua',
          },
        },
      })
    end,
  },
})
