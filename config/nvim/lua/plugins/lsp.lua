return {
  'nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  after = function()
    require('config.lsp_handlers').setup()

    local servers = {
      'lua_ls',
      'nixd',
      'nil_ls',
      'bashls',
      'kdl',
      'taplo',
      'emmet_ls',
      'jsonls',
      'marksman',
      'yamlls',

      -- Web Developlment
      'tsc',
      'tailwindcss',
      'oxlint',
      'oxfmt',
      'svelte',
      'astro',
      'elixirls',
      'expert',
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    -- vim.lsp.codelens.enable(true)
  end,
}
