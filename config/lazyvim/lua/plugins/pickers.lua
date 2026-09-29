return {
  {
    'ziontee113/color-picker.nvim',
    keys = {
      { '<leader>fc', '<cmd>PickColor<cr>', desc = 'Color Picker' }, -- Fixed space error and brackets
      { '<leader>fcc', '<cmd>PickColorInsert<cr>', desc = 'HTML Color Picker' },
      { '<leader>fcx', '<cmd>ConvertHEXandRGB<cr>', desc = 'Convert Hex and RGB' },
      { '<leader>fcv', '<cmd>ConvertHEXandHSL<cr>', desc = 'Convert Hex and HSL' },
    },
    config = function() require('color-picker') end,
  },
  {
    'ziontee113/icon-picker.nvim',
    keys = {
      -- These will force an override on top of LazyVim defaults
      { '<leader>sH', '<cmd>IconPickerInsert html_colors<cr>', desc = 'HTML Color Picker' },
      { '<leader>s.', '<cmd>IconPickerInsert emoji<cr>', desc = 'Emoji Picker' },
      { '<leader>se', '<cmd>IconPickerInsert emoji<cr>', desc = 'Emoji Picker' },
      { '<leader>sE', '<cmd>IconPickerInsert symbols nerd_font_v3<cr>', desc = 'Icon Picker - symbols and fonts' },
    },
    config = function()
      require('icon-picker').setup({
        disable_legacy_commands = true,
      })
    end,
  },
}
