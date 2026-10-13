return {
  {
    'luasnip',
    load_before = { 'blink.cmp' },
    on_require = { 'luasnip' },
    after = function(_)
      local luasnip = require('luasnip')
      luasnip.config.set_config({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
      })
      -- Load friendly-snippets from runtimepath
      require('luasnip.loaders.from_vscode').lazy_load()
      -- Load custom snippets from config snippets/ directory
      local snippet_dir = (vim.env.NVIM_DEV_CONFIG or vim.fn.stdpath('config')) .. '/snippets'
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { snippet_dir },
      })
      require('luasnip.loaders.from_lua').lazy_load({
        paths = { snippet_dir },
      })
    end,
  },
  { 'friendly-snippets', load_before = { 'luasnip' } },
}
