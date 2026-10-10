nixInfo.lze.load({
  {
    'bufferline.nvim',
    auto_enable = true,
    after = function()
      require('bufferline').setup({
        options = {
          close_command = function(n) Snacks.bufdelete(n) end,
          right_mouse_command = function(n) Snacks.bufdelete(n) end,
          diagnostics = 'nvim_lsp',

          diagnostics_indicator = function(_, _, diag)
            local icons = require('config.icons').diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
              .. (diag.warning and icons.Warn .. diag.warning or '')
            return vim.trim(ret)
          end,
          always_show_bufferline = false,
          show_buffer_close_icons = false,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          show_close_icon = false,
          themable = true,
          indicator = {
            icon = ' ',
            style = 'icon',
          },
          separator_style = { '', '' },
          offsets = {
            {
              filetype = 'oil',
            },
            {
              filetype = 'snacks_layout_box',
            },
            {
              filetype = 'snacks_picker_list',
            },
          },
          name_formatter = function(buf)
            if buf.tabnr then
              local ok, name = pcall(vim.api.nvim_tabpage_get_var, buf.tabnr, 'name')
              if ok and name then return name end
            end
          end,
        },
        highlights = {
          indicator_selected = {
            fg = '#cba6f7',
            bg = 'none',
          },
          fill = { bg = 'none' },
          background = { bg = 'none' },
          buffer_selected = { bg = 'none', fg = '#cba6f7' },
          buffer_visible = { bg = 'none', fg = '#a6adc8' },
          close_button = { bg = 'none' },
          close_button_selected = { bg = 'none' },
          close_button_visible = { bg = 'none' },
          duplicate = { bg = 'none' },
          duplicate_selected = { bg = 'none' },
          duplicate_visible = { bg = 'none' },
          error = { bg = 'none' },
          error_selected = { bg = 'none' },
          error_visible = { bg = 'none' },
          hint = { bg = 'none' },
          hint_selected = { bg = 'none' },
          hint_visible = { bg = 'none' },
          indicator_visible = { bg = 'none' },
          info = { bg = 'none' },
          info_selected = { bg = 'none' },
          info_visible = { bg = 'none' },
          modified = { bg = 'none' },
          modified_selected = { bg = 'none' },
          modified_visible = { bg = 'none' },
          numbers = { bg = 'none' },
          numbers_selected = { bg = 'none' },
          numbers_visible = { bg = 'none' },
          offset_separator = { bg = 'none' },
          pick = { bg = 'none' },
          pick_selected = { bg = 'none' },
          pick_visible = { bg = 'none' },
          separator = { bg = 'none' },
          separator_selected = { bg = 'none' },
          separator_visible = { bg = 'none' },
          tab = { bg = 'none' },
          tab_close = { bg = 'none' },
          tab_selected = { bg = 'none' },
          tab_separator = { bg = 'none' },
          tab_separator_selected = { bg = 'none' },
          trunc_marker = { bg = 'none' },
          warning = { bg = 'none' },
          warning_selected = { bg = 'none' },
          warning_visible = { bg = 'none' },
        },
      })

      vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
          vim.schedule(function() pcall(nvim_bufferline) end)
        end,
      })

      vim.keymap.set('n', '<A-1>', function() require('bufferline').go_to(1, true) end, { desc = 'Go to first buffer' })
      vim.keymap.set(
        'n',
        '<A-2>',
        function() require('bufferline').go_to(2, true) end,
        { desc = 'Go to second buffer' }
      )
      vim.keymap.set('n', '<A-3>', function() require('bufferline').go_to(3, true) end, { desc = 'Go to third buffer' })
      vim.keymap.set(
        'n',
        '<A-4>',
        function() require('bufferline').go_to(4, true) end,
        { desc = 'Go to fourth buffer' }
      )
      vim.keymap.set('n', '<A-5>', function() require('bufferline').go_to(5, true) end, { desc = 'Go to fifth buffer' })
      vim.keymap.set('n', '<A-6>', function() require('bufferline').go_to(6, true) end, { desc = 'Go to sixth buffer' })
      vim.keymap.set('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', { desc = 'Toggle Pin' })
      vim.keymap.set(
        'n',
        '<leader>bP',
        '<Cmd>BufferLineGroupClose ungrouped<CR>',
        { desc = 'Delete Non-Pinned Buffers' }
      )
      vim.keymap.set('n', '<leader>br', '<Cmd>BufferLineCloseRight<CR>', { desc = 'Delete Buffers to the Right' })
      vim.keymap.set('n', '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', { desc = 'Delete Buffers to the Left' })
      vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
      vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
      vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
      vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
      vim.keymap.set('n', '[B', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move buffer prev' })
      vim.keymap.set('n', ']B', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move buffer next' })
    end,
  },
})
