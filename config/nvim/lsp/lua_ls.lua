return {
  settings = {
    Lua = {
      signatureHelp = { enable = false },
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        globals = { 'vim', 'nixInfo', 'Snacks', 'lzn', 'Util', 'Icons' },
        disable = { 'missing-fields' },
      },
      telemetry = { enable = false },
    },
  },
}
