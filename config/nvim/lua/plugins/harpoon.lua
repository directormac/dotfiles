return {
  {
    -- Configuration Reference https://github.com/ThePrimeagen/harpoon/tree/harpoon2#config
    'harpoon2',
    event = 'DeferredUIEnter',
    load_before = { 'harpoon-lualine' },
    after = function()
      local harpoon = require('harpoon')
      harpoon:setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 4,
        },
        settings = {
          save_on_toggle = true,
        },
      })
    end,
    keys = function()
      local keys = {
        {
          '<leader>H',
          function() require('harpoon'):list():add() end,
          desc = 'Harpoon File',
        },
        {
          '<leader>h',
          function()
            local harpoon = require('harpoon')
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = 'Harpoon Quick Menu',
        },
      }

      for i = 1, 9 do
        table.insert(keys, {
          '<leader>' .. i,
          function() require('harpoon'):list():select(i) end,
          desc = 'Harpoon to File ' .. i,
        })
      end
      return keys
    end,
  },
  {
    'harpoon-lualine',
    load_before = { 'lualine.nvim' },
    lazy = true,
  },
}
