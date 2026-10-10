-- nixd trigger. The server settings live in `lsp/nixd.lua` on 'runtimepath',
-- see `:h lsp-config-merge`.
return {
  {
    'nixd',
    lsp = {
      filetypes = { 'nix' },
    },
  },
  {
    'nil_ls',
    lsp = {
      filetypes = { 'nix' },
    },
  },
}
