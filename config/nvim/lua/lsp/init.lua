-- nvim-lspconfig: the `lsp` field of a spec is a function called when the spec loads
-- on the matching filetype. Every language spec under lsp/ relies on it.
return {
  {
    'nvim-lspconfig',
    auto_enable = true,
    -- NOTE: define a function for lsp,
    -- and it will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    -- set up our on_attach function once before the spec loads
    before = function(_)
      vim.lsp.config('*', {
        on_attach = function(_, bufnr)
          -- we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local nmap = function(keys, func, desc)
            if desc then desc = 'LSP: ' .. desc end
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
          end

          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
          nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
          nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
          nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

          -- Focus inside popup (hover or diagnostic) or open hover documentation
          local hover_or_focus = function()
            local current_win = vim.api.nvim_get_current_win()
            local win_cfg = vim.api.nvim_win_get_config(current_win)
            -- If already inside a floating window, return focus to editing window
            if win_cfg.relative and win_cfg.relative ~= '' then
              vim.cmd('wincmd p')
              return
            end

            -- 1. Check if hover float window exists for this buffer
            local hover_win = vim.b[bufnr].lsp_floating_preview
            if hover_win and vim.api.nvim_win_is_valid(hover_win) then
              vim.api.nvim_set_current_win(hover_win)
              return
            end

            -- 2. Check if any other focusable floating window is visible in this tab
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if win ~= current_win and vim.api.nvim_win_is_valid(win) then
                local cfg = vim.api.nvim_win_get_config(win)
                if cfg.relative and cfg.relative ~= '' and cfg.focusable ~= false then
                  vim.api.nvim_set_current_win(win)
                  return
                end
              end
            end

            -- 3. If no float is currently open, trigger hover and focus it
            vim.lsp.buf.hover({ border = 'rounded', focus = true, silent = true })
          end

          nmap('K', hover_or_focus, 'Hover Documentation / Focus Popup')
          nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap(
            '<leader>wl',
            function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
            '[W]orkspace [L]ist Folders'
          )

          -- Create a command `:Format` local to the LSP buffer
          vim.api.nvim_buf_create_user_command(
            bufnr,
            'Format',
            function(_) vim.lsp.buf.format() end,
            { desc = 'Format current buffer with LSP' }
          )
        end,
      })
    end,
  },
}
