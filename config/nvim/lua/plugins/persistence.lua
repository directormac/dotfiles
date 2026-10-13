return {
  'persistence.nvim',
  event = 'DeferredUIEnter',
  keys = {

    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },

    { '<leader>qS', function() require('persistence').select() end, desc = 'Select and load a session.' },
    {
      '<leader>ql',
      function() require('persistence').load({ last = true }) end,
      desc = 'Restore Last Session',
    },

    { '<leader>qd', function() require('persistence').stop() end, desc = "Don't Save Current Session" },
  },
  before = function()
    -- Session options: include globals so bufferline pinned buffers persist across sessions
    vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
  end,
  opts = {},
  -- after = function(plugin)
  --   require('persistence').setup(plugin.opts or {})
  --
  --   -- -- Clean up hidden buffers before saving a session
  --   -- local function delete_hidden_buffers()
  --   --   local visible = {}
  --   --   for _, win in pairs(vim.api.nvim_list_wins()) do
  --   --     visible[vim.api.nvim_win_get_buf(win)] = true
  --   --   end
  --   --   for _, buf in pairs(vim.api.nvim_list_bufs()) do
  --   --     if not visible[buf] and vim.api.nvim_buf_is_valid(buf) then
  --   --       local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
  --   --       if buftype == '' then pcall(vim.api.nvim_buf_delete, buf, {}) end
  --   --     end
  --   --   end
  --   -- end
  --   --
  --   -- vim.api.nvim_create_autocmd('User', {
  --   --   pattern = 'PersistenceSavePre',
  --   --   group = vim.api.nvim_create_augroup('persistence_user', { clear = true }),
  --   --   callback = delete_hidden_buffers,
  --   -- })
  -- end,
}
