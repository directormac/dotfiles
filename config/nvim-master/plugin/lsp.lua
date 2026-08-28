require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig', version = vim.version.range('*') },
    { src = 'https://github.com/j-hui/fidget.nvim' },
  })

  require('fidget').setup({})
  -- Extend LSP capabilities with blink.cmp completions for all servers.
  -- Guarded because this runs before vim.lsp.enable() below: an error here
  -- would abort the whole callback and silently leave every server disabled,
  -- with nothing pointing at completion as the cause.
  local ok, capabilities = pcall(function() return require('blink.cmp').get_lsp_capabilities() end)
  if ok then
    vim.lsp.config('*', { capabilities = capabilities })
  else
    vim.notify('blink.cmp capabilities unavailable: ' .. tostring(capabilities), vim.log.levels.WARN)
  end

  ---@type lsp
  local servers = {
    bash_ls = {},
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    -- ts_ls = {},

    taplo = {},

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath('config')
            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
          then
            return
          end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          -- Define runtime properties. Use 'LuaJIT', as it is built into Neovim.
          -- runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?/init.lua' },
          },
          workspace = {
            -- Don't analyze code from submodules
            ignoreSubmodules = true,
            checkThirdParty = false,
            -- library = { vim.env.VIMRUNTIME },
            -- -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            -- --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end

  -- Enable codelens globally
  vim.lsp.codelens.enable(true)

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buf = args.buf

      if client then
        -- Disable codelens for lua (lua_ls "0 References" is noisy)
        if client.name == 'lua_ls' then vim.lsp.codelens.enable(false, { bufnr = buf }) end

        -- LSP folding (override treesitter default from init.lua)
        if client:supports_method('textDocument/foldingRange', buf) then
          require('fold').lsp_foldexpr(vim.api.nvim_get_current_win())
        end

        -- Workspace diagnostics
        -- if client:supports_method('workspace/diagnostic', buf) then
        --   vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
        -- else
        --   if Config.use_workspace_diagnostics_plugin then
        --     require('workspace-diagnostics').populate_workspace_diagnostics(client, buf)
        --   end
        -- end

        -- Inline completion
        if client:supports_method('textDocument/inlineCompletion', buf) then vim.lsp.inline_completion.enable(true) end

        -- Linked editing (e.g., paired HTML tags)
        if client:supports_method('textDocument/linkedEditingRange', buf) then
          vim.lsp.linked_editing_range.enable(true, { bufnr = buf })
        end

        -- Inline color swatches
        if client:supports_method('textDocument/documentColor', buf) then
          vim.lsp.document_color.enable(true, { bufnr = buf })
        end

        -- Format on typing trigger characters
        -- NOTE: I think I rather use conform.nvim as otherwise this yields unexpected results.
        -- if client:supports_method("textDocument/onTypeFormatting", buf) then
        --   vim.lsp.on_type_formatting.enable(true, { bufnr = buf })
        -- end
      end

      -- Keymaps
      -- LSP keymaps not covered by snacks picker (gd, gD, gr, gI, gt are in snacks.lua)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf, desc = 'Hover' })
      vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { buffer = buf, desc = 'Rename' })
      vim.keymap.set('n', '<leader>cR', Snacks.rename.rename_file, { buffer = buf, desc = 'Rename file' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = buf, desc = 'Code action' })
      vim.keymap.set('n', '<leader>cc', vim.lsp.codelens.run, { buffer = buf, desc = 'Run codelens' })
      vim.keymap.set(
        { 'n', 'x' },
        '<M-o>',
        function() vim.lsp.buf.selection_range(1) end,
        { buffer = buf, desc = 'Expand selection (LSP)' }
      )
      vim.keymap.set(
        'x',
        '<M-i>',
        function() vim.lsp.buf.selection_range(-1) end,
        { buffer = buf, desc = 'Shrink selection (LSP)' }
      )
      vim.keymap.set(
        'n',
        '<leader>uh',
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
        { buffer = buf, desc = 'Toggle inlay hints' }
      )
      vim.keymap.set('n', '<leader>ul', function()
        local enabled = not vim.lsp.codelens.is_enabled()
        vim.lsp.codelens.enable(enabled)
        vim.notify('Codelens: ' .. (enabled and 'on' or 'off'))
      end, { buffer = buf, desc = 'Toggle codelens' })
      vim.keymap.set(
        'n',
        '[d',
        function() vim.diagnostic.jump({ count = -1 }) end,
        { buffer = buf, desc = 'Prev diagnostic' }
      )
      vim.keymap.set(
        'n',
        ']d',
        function() vim.diagnostic.jump({ count = 1 }) end,
        { buffer = buf, desc = 'Next diagnostic' }
      )
    end,
  })

  -- Reset diagnostics on detach so :lsp restart/:lsp stop don't leave stale state.
  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('lsp-detach-cleanup', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      local prefix = ('nvim.lsp.%s.%d'):format(client.name, client.id)
      for namespace, metadata in pairs(vim.diagnostic.get_namespaces()) do
        local name = metadata.name or ''
        if name == prefix or vim.startswith(name, prefix .. '.') then vim.diagnostic.reset(namespace) end
      end
    end,
  })

  -- LSP progress spinner
  vim.api.nvim_create_autocmd('LspProgress', {
    group = vim.api.nvim_create_augroup('lsp-progress', { clear = true }),
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
      vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
        id = 'lsp_progress',
        title = 'LSP Progress',
        opts = function(notif)
          notif.icon = ev.data.params.value.kind == 'end' and ' '
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end)
