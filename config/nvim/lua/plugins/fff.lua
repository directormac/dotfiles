return {
  'fff.nvim',
  cmd = {
    'FFFFind',
    'FFFScan',
    'FFFResume',
    'FFFLiveGrep',
    'FFFRefreshGit',
    'FFFClearCache',
    'FFFHealth',
    'FFFDebug',
    'FFFOpenLog',
  },
  keys = {
    -- Primary file finders
    {
      '<leader><leader>',
      function() require('fff').find_files({ cwd = require('config.util').root() }) end,
      desc = 'Find Files (fff)',
    },
    {
      '<leader>ff',
      function() require('fff').find_files({ cwd = require('config.util').cwd() }) end,
      desc = 'Find Files (cwd) (fff)',
    },
    {
      '<leader>fF',
      function() require('fff').find_files({ cwd = require('config.util').root() }) end,
      desc = 'Find Files (root) (fff)',
    },
    -- Grep
    {
      '<leader>/',
      function() require('fff').live_grep({ cwd = require('config.util').root() }) end,
      desc = 'Grep (root) (fff)',
    },
    {
      '<leader>sg',
      function() require('fff').live_grep({ cwd = require('config.util').cwd() }) end,
      desc = 'Grep (cwd) (fff)',
    },
    {
      '<leader>sG',
      function() require('fff').live_grep({ cwd = require('config.util').root() }) end,
      desc = 'Grep (root) (fff)',
    },
    {
      '<leader>sw',
      function() require('fff').live_grep_under_cursor({ cwd = require('config.util').cwd() }) end,
      mode = { 'n', 'x' },
      desc = 'Grep word/selection (cwd) (fff)',
    },
    {
      '<leader>sW',
      function() require('fff').live_grep_under_cursor({ cwd = require('config.util').root() }) end,
      mode = { 'n', 'x' },
      desc = 'Grep word/selection (root) (fff)',
    },
    {
      '<leader>fw',
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection (fff)',
    },
    -- Utilities
    {
      '<leader>fR',
      function() require('fff').resume() end,
      desc = 'Resume last FFF search',
    },
    {
      '<leader>fc',
      function() require('fff').open_file_under_cursor() end,
      desc = 'Open file under cursor (fff)',
    },
  },
  after = function()
    require('fff').setup({
      prompt = ' ',
      layout = {
        prompt_position = 'top',
        preview_position = 'right',
        preview_size = 0.4,
      },
      preview = {
        enabled = true,
        line_numbers = true,
      },
      git = {
        status_text_color = true,
      },
      grep = {
        smart_case = true,
        trim_whitespace = true,
      },
    })
  end,
}
