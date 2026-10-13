return {
  'nvim-surround',
  event = 'DeferredUIEnter',
  before = function()
    -- We provide our own gs*/<C-g>s mappings in `keys`, so remove all of
    -- nvim-surround's built-in defaults (ys/yss/yS/ySS/ds/cs/cS, S/gS,
    -- <C-g>s/<C-g>S) to avoid conflicts with other plugins.
    vim.g.nvim_surround_no_mappings = true
  end,

  keys = {
    {
      'gsa',
      function() return require('nvim-surround').normal_surround({ line_mode = false }) end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Add Surrounding',
    },
    {
      'gss',
      function() return require('nvim-surround').normal_surround({ line_mode = false }) .. 'Vg_' end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Add Surrounding to Line',
    },
    {
      'gsA',
      function() return require('nvim-surround').normal_surround({ line_mode = true }) end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Add Surrounding (New Line)',
    },
    {
      'gsS',
      function()
        return '^' .. tostring(vim.v.count1) .. require('nvim-surround').normal_surround({ line_mode = true }) .. 'g_'
      end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Add Surrounding to Line (New Line)',
    },
    {
      'gsa',
      function()
        local curpos = require('nvim-surround.buffer').get_curpos()
        return string.format(
          ":lua require'nvim-surround'.visual_surround({ line_mode = false, curpos = { %d, %d }, curswant = %d })<CR>",
          curpos[1],
          curpos[2],
          vim.fn.winsaveview().curswant
        )
      end,
      mode = 'x',
      expr = true,
      silent = true,
      desc = 'Add Surrounding',
    },
    {
      'gsA',
      function()
        local curpos = require('nvim-surround.buffer').get_curpos()
        return string.format(
          ":lua require'nvim-surround'.visual_surround({ line_mode = true, curpos = { %d, %d }, curswant = 0 })<CR>",
          curpos[1],
          curpos[2]
        )
      end,
      mode = 'x',
      expr = true,
      silent = true,
      desc = 'Add Surrounding (New Line)',
    },
    {
      'gsd',
      function() return require('nvim-surround').delete_surround() end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Delete Surrounding',
    },
    {
      'gsr',
      function() return require('nvim-surround').change_surround({ line_mode = false }) end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Replace Surrounding',
    },
    {
      'gsR',
      function() return require('nvim-surround').change_surround({ line_mode = true }) end,
      mode = 'n',
      expr = true,
      silent = true,
      desc = 'Replace Surrounding (New Line)',
    },
    -- {
    --   '<C-g>s',
    --   function() require('nvim-surround').insert_surround({ line_mode = false }) end,
    --   mode = 'i',
    --   silent = true,
    --   desc = 'Add Surrounding (insert)',
    -- },
    -- {
    --   '<C-g>S',
    --   function() require('nvim-surround').insert_surround({ line_mode = true }) end,
    --   mode = 'i',
    --   silent = true,
    --   desc = 'Add Surrounding (insert, new lines)',
    -- },
  },

  after = function(plugin)
    -- Default Configuration https://github.com/kylechui/nvim-surround/blob/main/lua/nvim-surround/config.lua
    require('nvim-surround').setup()
  end,
}
