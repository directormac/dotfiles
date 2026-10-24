return {
  {
    'wakatime',
    lazy = false,
    after = function()
      vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWritePost' }, {
        group = vim.api.nvim_create_augroup('wakatime_lualine_refresh', { clear = true }),
        callback = function()
          if package.loaded['lualine'] then require('lualine').refresh({ place = { 'statusline' } }) end
        end,
      })
    end,
  },
}
