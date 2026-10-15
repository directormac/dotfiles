return {
  {
    'nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    on_require = { 'lspconfig' },
    after = function()
      require('lsp_handlers').setup()

      local servers = {
        'copilot',
        'lua_ls',
        'nixd',
        'nil_ls',
        'bashls',
        'kdl_lsp',
        'taplo',
        'emmet_language_server',
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

      -- Scope tailwindcss filetypes to active web languages
      vim.lsp.config('tailwindcss', {
        filetypes = {
          'html',
          'css',
          'scss',
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'svelte',
          'astro',
          'vue',
          'heex',
          'elixir',
        },
      })

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },
}
