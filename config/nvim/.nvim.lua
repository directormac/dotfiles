-- Project configuration for Neovim config directory
-- Loaded automatically via vim.o.exrc = true when editing within ~/.config/nvim or config/nvim

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { 'vim', 'nixInfo', 'Snacks', 'lzn', 'Util', 'Icons' },
        disable = { 'missing-fields' },
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})
