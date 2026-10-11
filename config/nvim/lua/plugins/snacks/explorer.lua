local M = {}

M.opts = {
  explorer = {
    replace_netrw = true,
  },
  picker = {
    sources = {
      explorer = {
        auto_close = true,
      },
    },
  },
}

function M.keys()
  vim.keymap.set('n', '<leader>e', function() Snacks.explorer.open() end, { desc = 'File Explorer (Snacks)' })
end

return M
