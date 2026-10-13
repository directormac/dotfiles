return {
  'snacks.nvim',
  keys = {
    { '<leader>gl', function() Snacks.lazygit.open() end, desc = 'Lazygit (Float)' },
    { '<leader>glf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit file' },
    { '<leader>gll', function() Snacks.lazygit.log() end, desc = 'Lazygit Log' },
  },
  before = function()
    -- Backend handler for remote commands from lazygit
    nixInfo.lazygit_fix = function(path, line)
      local prev = vim.fn.bufnr('#')
      local prev_win = vim.fn.bufwinid(prev)
      vim.api.nvim_feedkeys('q', 'n', false)
      if line then
        vim.api.nvim_buf_call(prev, function()
          vim.cmd.edit(path)
          local buf = vim.api.nvim_get_current_buf()
          vim.schedule(function()
            if buf then
              vim.api.nvim_win_set_buf(prev_win, buf)
              vim.api.nvim_win_set_cursor(0, { line or 0, 0 })
            end
          end)
        end)
      else
        vim.api.nvim_buf_call(prev, function()
          vim.cmd.edit(path)
          local buf = vim.api.nvim_get_current_buf()
          vim.schedule(function()
            if buf then vim.api.nvim_win_set_buf(prev_win, buf) end
          end)
        end)
      end
    end
  end,
  opts = {
    ---@type snacks.lazygit.Config
    lazygit = {
      configure = true,
      win = {
        style = 'lazygit',
      },
      config = {
        os = {
          editPreset = 'nvim-remote',
          edit = vim.v.progpath
            .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
          editAtLine = vim.v.progpath
            .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
          openDirInEditor = vim.v.progpath
            .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
          -- this one isnt a remote command, make sure it gets our config regardless of if we name it nvim or not
          editAtLineAndWait = nixInfo(vim.v.progpath, 'progpath') .. ' +{{line}} {{filename}}',
        },
      },
    },
  },
}
