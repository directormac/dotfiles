return {

  {
    'conform.nvim',
    on_require = { 'conform' },
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cF',
        function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end,
        mode = { 'n', 'x' },
        desc = 'Format Injected Langs',
      },
    },
    opts = {
      format_on_save = function()
        if not vim.g.auto_format then return end
        return { timeout_ms = 5000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        nix = { 'nixfmt' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        toml = { 'taplo' },
        kdl = { 'kdlfmt' },
        yaml = { 'yamlfmt' },
        json = { 'oxfmt' },
        jsonc = { 'oxfmt' },
        javascript = { 'oxfmt' },
        typescript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
      },
    },
    before = function(plugin)
      if vim.g.auto_format == nil then vim.g.auto_format = true end
    end,
  },
}
