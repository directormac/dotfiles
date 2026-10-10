return {
  'nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  after = function()
    require('config.lsp_handlers').setup()

    -- Language servers enabled via Neovim 0.11+ native LSP engine
    local servers = {
      'lua_ls',
      'nixd',
      'nil_ls',
      'bashls',
      'rust_analyzer',
      'elixirls',
      'vtsls',
      'tailwindcss',
      'marksman',
      'svelte',
      'astro',
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end
  end,
}
