return {
  'nvim-lint',
  event = { 'BufWritePost', 'BufReadPost' },
  after = function(plugin)
    require('lint').linters_by_ft = {
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      javascript = { 'oxlint' },
      typescript = { 'oxlint' },
      javascriptreact = { 'oxlint' },
      typescriptreact = { 'oxlint' },
    }

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function() require('lint').try_lint() end,
    })
  end,
}
