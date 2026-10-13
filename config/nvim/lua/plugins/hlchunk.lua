return {
  'hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    chunk = {
      enable = true,
      duration = 100,
      delay = 500,
      chars = {
        horizontal_line = '┅',
        left_top = '┏',
        vertical_line = '┇',
        left_bottom = '┗',
        right_arrow = '┅',
      },
    },
    blank = {
      enable = true,
      chars = {
        ' ',
        '․',
        '⁚',
        '⁖',
        '⁘',
        '⁙',
      },
      style = {
        '#585b70',
        '#45475a',
        '#313244',
      },
    },
    line_num = {
      enable = true,
      style = '#cba6f7',
    },
    indent = {
      enable = false,
      chars = {
        '│',
        '¦',
        '┆',
        '┊',
      },
      style = {
        '#f38ba8',
        '#fab387',
        '#f9e2af',
        '#a6e3a1',
        '#94e2d5',
        '#89b4fa',
        '#cba6f7',
        '#f5c2e7',
        '#cba6f7',
        '#89b4fa',
      },
    },
  },
}
