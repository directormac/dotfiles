nixInfo.lze.load({
  {
    'nvim-lint',
    auto_enable = true,
    event = 'FileType',
    after = function(plugin)
      require('lint').linters_by_ft = {
        sh = { 'shellcheck' },
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function() require('lint').try_lint() end,
      })
    end,
  },
})
