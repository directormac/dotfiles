return {
  {
    'ziontee113/color-picker.nvim',
    keys = {
      {
        '<leader>fc ',
        '<cmd>PickColor<cr>',
        { desc = 'Color Picker' },
      },
      {
        '<leader>fcc',
        '<cmd>PickColorInsert<cr>',
        { desc = 'HTML Color Picker' },
      },
      {
        '<leader>fcx',
        '<cmd>ConvertHEXandRGB<cr>',
        { desc = 'Convert Hex and RGB' },
      },
      {
        '<leader>fcv',
        '<cmd>ConvertHEXandHSL<cr>',
        { desc = 'Convert Hex and HSL' },
      },
    },
    config = function() require('color-picker') end,
  },
  {
    'ziontee113/icon-picker.nvim',
    keys = {
      {
        '<leader>fh',
        '<cmd>IconPickerInsert html_colors<cr>',
        { desc = 'HTML Color Picker' },
      },
      {
        '<leader>..',
        '<cmd>IconPickerInsert emoji<cr>',
        { desc = 'Emoji Picker' },
      },
      {
        '<leader>. ',
        '<cmd>IconPickerInsert emoji<cr>',
        { desc = 'Emoji Picker' },
      },
      {
        '<leader>./',
        '<cmd>IconPickerInsert symbols nerd_font_v3<cr>',
        { desc = 'Icon Picker - symbols and fonts' },
      },
    },
    config = function()
      require('icon-picker').setup({
        disable_legacy_commands = true,
      })
    end,
  },
}
