-- lua_ls trigger. The server settings live in `lsp/lua_ls.lua` on 'runtimepath',
-- see `:h lsp-config-merge`.
return {
  {
    -- name of the lsp
    'lua_ls',
    for_cat = 'lua',
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options,
    -- but with a default on_attach and capabilities
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
      -- (meaning it doesn't call the callback function we defined in the main init.lua)
      filetypes = { 'lua' },
    },
    -- also these are regular specs and you can use before and after and all the other normal fields
  },
}
