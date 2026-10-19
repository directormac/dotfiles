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
        'rust_analyzer',

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

      -- tmux configuration files (and the tmux blocks that are embedded in
      -- Nix files, which otter.nvim exposes as `tmux` buffers).
      vim.lsp.config('tmux_ls', {
        cmd = { 'tmux-language-server' },
        filetypes = { 'tmux' },
        root_markers = { '.git', '.tmux.conf', 'tmux.conf' },
      })

      vim.lsp.enable('copilot')

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      vim.lsp.enable('tmux_ls')
    end,
  },
}
