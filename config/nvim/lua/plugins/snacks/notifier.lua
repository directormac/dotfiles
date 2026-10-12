local M = {}

M.opts = {
  notifier = {
    enable = true,
  },
  notify = {
    enable = true,
  },
}

function M.keys()
  vim.keymap.set('n', '<leader>n', function() Snacks.notifier.show_history() end, { desc = 'Notification History' })
  vim.keymap.set('n', '<leader>un', function() Snacks.notifier.hide() end, { desc = 'Dismiss All Notifications' })
end

return M
