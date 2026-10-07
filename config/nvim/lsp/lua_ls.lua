---@brief
--- lua-language-server settings.
---
--- This file is on 'runtimepath', so neovim merges it into `vim.lsp.config('lua_ls')`
--- when the client starts. See `:h lsp-config-merge`.
--- The trigger spec (which filetypes activate the server) lives in `lua/lsp/lua.lua`.
return {
  settings = {
    Lua = {
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { 'nixInfo', 'vim' },
        disable = { 'missing-fields' },
      },
    },
  },
}
