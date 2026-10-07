---@brief
--- nixd settings.
---
--- This file is on 'runtimepath', so neovim merges it into `vim.lsp.config('nixd')`
--- when the client starts. See `:h lsp-config-merge`.
--- The trigger spec (which filetypes activate the server) lives in `lua/lsp/nix.lua`.
return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = [[import <nixpkgs> {}]],
      },
      options = {},
      formatting = {
        command = { 'nixfmt' },
      },
      diagnostic = {
        suppress = {
          'sema-escaping-with',
        },
      },
    },
  },
}
