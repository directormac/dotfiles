return {
  'snacks.nvim',
  keys = {
    { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
    { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
  },
  opts = {
    notifier = {
      enable = true,
    },
    notify = {
      enable = true,
    },
  },
}
