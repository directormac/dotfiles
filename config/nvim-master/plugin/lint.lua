require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://codeberg.org/mfussenegger/nvim-lint' },
  })

  local lint = require('lint')

  lint.linters_by_ft = {}

  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
    group = vim.api.nvim_create_augroup('lint', { clear = true }),
    callback = function() lint.try_lint() end,
  })

  -- Lint already-open buffers (initial file was read before VimEnter)
  lint.try_lint()
end)
