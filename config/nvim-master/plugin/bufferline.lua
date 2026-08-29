require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range('*') },
  })

  require('bufferline').setup({
    options = {
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = 'nvim_lsp',
      always_show_bufferline = false,
      show_buffer_close_icons = false,
      show_duplicate_prefix = true,
      persist_buffer_sort = true,
      show_close_icon = false,
      indicator = {
        icon = ' ',
        style = 'icon',
      },

      highlight = {
        indicator_selected = {
          fg = '#cba6f7',
        },
      },

      offsets = {
        {
          filetype = 'oil',
          text = 'file explorer',
          highlight = 'Directory',
          text_align = 'left',
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
