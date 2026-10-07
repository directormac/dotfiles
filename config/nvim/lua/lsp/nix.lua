-- nixd trigger. The server settings live in `lsp/nixd.lua` on 'runtimepath',
-- see `:h lsp-config-merge`.
return {
  {
    'nixd',
    enabled = nixInfo.isNix, -- mason doesn't have nixd
    for_cat = 'nix',
    lsp = {
      filetypes = { 'nix' },
    },
  },
}
