local M = {}

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(ev)
      local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end
        vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
      end

      local hover_or_focus = Utils.hover_or_focus

      nmap('<leader>c?', function() Snacks.picker.lsp_config() end, 'Active Language Servers')

      nmap('<leader>cc', vim.lsp.codelens.run, 'Run CodeLens')
      nmap('<leader>cl', function()
        local enabled = not vim.lsp.codelens.is_enabled()
        vim.lsp.codelens.enable(enabled)
        vim.notify('Codelens: ' .. (enabled and 'on' or 'off'))
      end, 'Toggle codelens')

      nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

      nmap('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition')
      nmap('gD', function() Snacks.picker.lsp_declarations() end, 'Goto Definition')

      -- nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
      vim.keymap.set(
        'n',
        'gr',
        function() Snacks.picker.lsp_references() end,
        { nowait = true, desc = 'LSP: References' }
      )
      nmap('gI', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
      nmap('gy', function() Snacks.picker.lsp_type_definitions() end, 'Type Definition')

      nmap('gai', function() Snacks.picker.lsp_incoming_calls() end, 'Calls Incoming')
      nmap('gao', function() Snacks.picker.lsp_outgoing_calls() end, 'Calls Ongoing')

      nmap('<leader>cwa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
      nmap('<leader>cwr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')

      nmap(
        '<leader>cwl',
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        'Workspace List Folders'
      )

      nmap('<leader>ss', function() Snacks.picker.lsp_symbols() end, 'Document Symbols')
      nmap('<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, 'Workspace Symbols')

      vim.keymap.set(
        { 'n', 'x' },
        '<M-o>',
        function() vim.lsp.buf.selection_range(1) end,
        { buffer = ev.buf, desc = 'Expand selection (LSP)' }
      )

      vim.keymap.set(
        'x',
        '<M-i>',
        function() vim.lsp.buf.selection_range(-1) end,
        { buffer = ev.buf, desc = 'Shrink selection (LSP)' }
      )

      nmap('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Prev diagnostic')
      nmap(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next diagnostic')

      nmap('<leader>cr', vim.lsp.buf.rename, 'Rename')

      nmap('K', hover_or_focus, 'Hover Documentation / Focus Popup')

      vim.keymap.set(
        'i',
        '<C-k>',
        vim.lsp.buf.signature_help,
        { buffer = ev.buf, desc = 'LSP: Signature Documentation' }
      )

      nmap('<leader>cL', function()
        vim.cmd('lsp restart')
        vim.notify('LSP restarted', vim.log.levels.INFO, { title = 'LSP' })
      end, 'Restart Language Server Attached')

      -- Enable LSP inline completion / ghost text only if server supports it and quota is not exhausted
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, ev.buf) then
        if _G.CopilotState == nil or _G.CopilotState.has_quota ~= false then
          vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
        end
        vim.keymap.set(
          'i',
          '<M-f>',
          vim.lsp.inline_completion.get,
          { buffer = ev.buf, desc = 'LSP: Accept inline completion' }
        )
        vim.keymap.set(
          'i',
          '<M-]>',
          vim.lsp.inline_completion.select,
          { buffer = ev.buf, desc = 'LSP: Cycle inline completion' }
        )
      end

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(
        ev.buf,
        'Format',
        function(_) vim.lsp.buf.format() end,
        { desc = 'Format current buffer with LSP' }
      )
    end,
  })

  _G.CopilotState = {
    has_quota = true,
    plan = nil,
    quota = nil,
    used = nil,
    percent_remaining = nil,
    unlimited = false,
  }

  local function update_copilot_quota(result)
    if not result or not result.completions then return end
    local comp = result.completions
    local unlimited = comp.unlimited == true
    local has_quota = unlimited
      or ((comp.percentRemaining or 0) > 0)
      or (comp.quota and comp.used and comp.used < comp.quota)

    _G.CopilotState = {
      plan = result.copilotPlan or 'unknown',
      quota = comp.quota,
      used = comp.used or comp.creditsUsed,
      percent_remaining = comp.percentRemaining,
      unlimited = unlimited,
      has_quota = has_quota,
    }

    if not has_quota then
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then pcall(vim.lsp.inline_completion.enable, false, { bufnr = bufnr }) end
      end
    end

    if package.loaded['lualine'] then require('lualine').refresh({ place = { 'statusline' } }) end
  end

  -- Copilot quota handlers
  vim.lsp.handlers['copilot/quotaChange'] = function(_, result) update_copilot_quota(result) end

  vim.lsp.handlers['copilot/quotaWarning'] = function(_, result)
    update_copilot_quota(result)
    if result and result.message then
      vim.notify(result.message, vim.log.levels.WARN, { title = 'GitHub Copilot Quota' })
    end
  end

  vim.api.nvim_create_user_command('CopilotStatus', function()
    local clients = vim.lsp.get_clients({ name = 'copilot' })
    if #clients == 0 then
      vim.notify('Copilot LSP is not running.', vim.log.levels.WARN, { title = 'Copilot' })
      return
    end
    local copilot = clients[1]
    copilot:request('checkStatus', vim.empty_dict(), function(err, res)
      if err then
        vim.notify(
          'Error checking Copilot status: ' .. tostring(err.message),
          vim.log.levels.ERROR,
          { title = 'Copilot' }
        )
        return
      end
      local quota_str = ''
      if _G.CopilotState then
        if _G.CopilotState.unlimited then
          quota_str = '\nPlan: Unlimited (' .. tostring(_G.CopilotState.plan) .. ')'
        elseif _G.CopilotState.quota then
          quota_str = string.format(
            '\nPlan: %s\nCompletions: %d/%d (%d%% remaining)%s',
            _G.CopilotState.plan or 'free',
            _G.CopilotState.used or 0,
            _G.CopilotState.quota or 0,
            _G.CopilotState.percent_remaining or 0,
            _G.CopilotState.has_quota and '' or ' [EXHAUSTED]'
          )
        end
      end
      local msg = string.format('Status: %s\nUser: %s%s', res.status or 'Unknown', res.user or 'None', quota_str)
      local level = (_G.CopilotState and _G.CopilotState.has_quota == false) and vim.log.levels.WARN
        or vim.log.levels.INFO
      vim.notify(msg, level, { title = 'GitHub Copilot' })
    end)
  end, { desc = 'Check Copilot LSP status' })

  -- -- Reset diagnostics on detach so :lsp restart/:lsp stop don't leave stale state.
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

  -- -- LSP progress spinner
  -- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
  -- local progress = vim.defaulttable()
  -- vim.api.nvim_create_autocmd('LspProgress', {
  --   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  --   callback = function(ev)
  --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
  --     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
  --     if not client or type(value) ~= 'table' then return end
  --     local p = progress[client.id]
  --
  --     for i = 1, #p + 1 do
  --       if i == #p + 1 or p[i].token == ev.data.params.token then
  --         p[i] = {
  --           token = ev.data.params.token,
  --           msg = ('[%3d%%] %s%s'):format(
  --             value.kind == 'end' and 100 or value.percentage or 100,
  --             value.title or '',
  --             value.message and (' **%s**'):format(value.message) or ''
  --           ),
  --           done = value.kind == 'end',
  --         }
  --         break
  --       end
  --     end
  --
  --     local msg = {} ---@type string[]
  --     progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)
  --
  --     local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  --     vim.notify(table.concat(msg, '\n'), 'info', {
  --       id = 'lsp_progress',
  --       title = client.name,
  --       opts = function(notif)
  --         notif.icon = #progress[client.id] == 0 and ' '
  --           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
  --       end,
  --     })
  --   end,
  -- })
end

return M
