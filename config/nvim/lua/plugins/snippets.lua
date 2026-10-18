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
        delete_check_events = 'TextChanged',
        region_check_events = 'CursorMoved,InsertEnter',
        enable_autosnippets = true,
      })

      local loaders = require('luasnip.loaders')

      -- Load friendly-snippets from runtimepath
      require('luasnip.loaders.from_vscode').lazy_load()

      -- Load custom snippets from config snippets/ directory
      local cfg_dir = (_G.nixInfo and _G.nixInfo(nil, 'settings', 'config_directory'))
        or vim.env.NVIM_DEV_CONFIG
        or vim.fn.stdpath('config')
      local snippet_dir = cfg_dir .. '/snippets'
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { snippet_dir },
      })
      require('luasnip.loaders.from_lua').lazy_load({
        paths = { snippet_dir },
      })

      -- Keymaps to abort/unlink an active snippet session cleanly
      vim.keymap.set('n', '<leader>cs', function()
        if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] then
          luasnip.unlink_current()
          vim.notify('Snippet session cleared', vim.log.levels.INFO, { title = 'LuaSnip' })
        else
          vim.notify('No active snippet session', vim.log.levels.WARN, { title = 'LuaSnip' })
        end
      end, { desc = 'Cancel active snippet session' })
    end,
  },
  { 'friendly-snippets', load_before = { 'luasnip' } },
}
