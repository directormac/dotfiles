return {
  'conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cF',
      function()
        require('conform').format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end,
      mode = { 'n', 'v' },
      desc = 'Format',
    },
  },
  after = function(plugin)
    if vim.g.auto_format == nil then vim.g.auto_format = true end

    local conform = require('conform')
    conform.setup({
      format_on_save = function()
        if not vim.g.auto_format then return end
        return { timeout_ms = 5000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        nix = { 'nixfmt' },
        sh = { 'shfmt' },
      },
    })
  end,
}
