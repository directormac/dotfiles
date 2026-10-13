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
        globals = { 'vim', 'nixInfo', 'Snacks', 'lze', 'Utils' },
        disable = { 'missing-fields' },
      },
      telemetry = { enable = false },
    },
  },
}
