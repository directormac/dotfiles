local M = {}

M.opts = {
  scratch = {},
}

function M.keys()
  vim.keymap.set('n', '<leader>.', function() Snacks.scratch() end, { desc = 'Toggle Scratch Buffer' })
  vim.keymap.set('n', '<leader>s.', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })
  vim.keymap.set('n', '<leader>S', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })
end

return M
