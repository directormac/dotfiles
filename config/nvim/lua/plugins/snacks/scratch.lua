local M = {}

M.opts = {
  scratch = {
    win_by_ft = {
      lua = {
        keys = {
          ['source'] = {
            '<cr>',
            function(self)
              local name = 'scratch.' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ':e')
              Snacks.debug.run({ buf = self.buf, name = name })
            end,
            desc = 'Source buffer',
            mode = { 'n', 'x' },
          },
        },
      },
    },
  },
}

function M.keys()
  vim.keymap.set('n', '<leader>.', function() Snacks.scratch() end, { desc = 'Toggle Scratch Buffer' })
  vim.keymap.set('n', '<leader>s.', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })
  vim.keymap.set('n', '<leader>S', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })
end

return M
