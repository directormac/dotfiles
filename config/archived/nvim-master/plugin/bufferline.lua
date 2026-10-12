require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range('*') },
  })

  -- Reference https://github.com/catppuccin/nvim#configuration
  require('bufferline').setup({
    options = {
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = 'nvim_lsp',

      diagnostics_indicator = function(_, _, diag)
        local icons = require('icons').diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
          .. (diag.warning and icons.Warn .. diag.warning or '')
        return vim.trim(ret)
      end,
      always_show_bufferline = false,
      show_buffer_close_icons = false,
      show_duplicate_prefix = true,
      persist_buffer_sort = true,
      show_close_icon = false,
      indicator = {
        icon = ' ',
        style = 'icon',
      },
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
      },
    },
  })

  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
    callback = function()
      vim.schedule(function() pcall(nvim_bufferline) end)
    end,
  })

  vim.keymap.set('n', '<A-1>', function() require('bufferline').go_to(1, true) end, { desc = 'Go to first buffer' })
  vim.keymap.set('n', '<A-2>', function() require('bufferline').go_to(2, true) end, { desc = 'Go to second buffer' })
  vim.keymap.set('n', '<A-3>', function() require('bufferline').go_to(3, true) end, { desc = 'Go to third buffer' })
  vim.keymap.set('n', '<A-4>', function() require('bufferline').go_to(4, true) end, { desc = 'Go to fourth buffer' })
  vim.keymap.set('n', '<A-5>', function() require('bufferline').go_to(5, true) end, { desc = 'Go to fifth buffer' })
  vim.keymap.set('n', '<A-6>', function() require('bufferline').go_to(6, true) end, { desc = 'Go to sixth buffer' })
  vim.keymap.set('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', { desc = 'Toggle Pin' })
  vim.keymap.set('n', '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', { desc = 'Delete Non-Pinned Buffers' })
  vim.keymap.set('n', '<leader>br', '<Cmd>BufferLineCloseRight<CR>', { desc = 'Delete Buffers to the Right' })
  vim.keymap.set('n', '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', { desc = 'Delete Buffers to the Left' })
  vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
  vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
  vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
  vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
  vim.keymap.set('n', '[B', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move buffer prev' })
  vim.keymap.set('n', ']B', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move buffer next' })
end)
