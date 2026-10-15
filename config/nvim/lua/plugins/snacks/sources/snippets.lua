local M = {}

---@param opts? snacks.picker.Config
function M.setup(opts)
  return vim.tbl_deep_extend('force', {
    title = 'Snippets',
    layout = { preset = 'vscode' },
    preview = 'preview',
    supports_live = false,
    sort = {
      fields = {
        'ft_priority',
        { name = 'score', desc = true },
        'name',
        'idx',
      },
    },
    format = function(item, picker)
      local name = Snacks.picker.util.align(item.name, (picker.align_1 or 20) + 5)
      local ft_label = item.ft ~= '' and ('[' .. item.ft .. ']') or '[all]'
      local ft_hl = item.ft ~= '' and 'DiagnosticOk' or 'SnacksPickerComment'
      local name_hl = item.ft ~= '' and 'DiagnosticWarn' or 'SnacksPickerLabel'
      return {
        { name, hl = name_hl },
        { string.format('%-8s', ft_label), hl = ft_hl },
        { ' ' .. (item.description or ''), hl = 'SnacksPickerComment' },
      }
    end,
    finder = function(_, ctx)
      local ok, luasnip = pcall(require, 'luasnip')
      if not ok then
        Snacks.notify.warn('Luasnip not loaded', { title = 'Snippets' })
        return {}
      end

      local current_buf = ctx and ctx.filter and ctx.filter.current_buf
      if
        not current_buf
        or not vim.api.nvim_buf_is_valid(current_buf)
        or vim.bo[current_buf].filetype == 'snacks_picker_input'
      then
        current_buf = vim.api.nvim_get_current_buf()
      end
      local target_ft = (current_buf and vim.api.nvim_buf_is_valid(current_buf) and vim.bo[current_buf].filetype)
        or vim.bo.ft
      if target_ft == 'snacks_picker_input' then target_ft = '' end

      local snippets = {}
      local seen = {}

      local function is_visible(snip)
        if snip.show_condition then
          local ok, res = pcall(function() return snip:show_condition('') end)
          if ok and res == false then return false end
          if not ok then
            local ok2, res2 = pcall(snip.show_condition, '')
            if ok2 and res2 == false then return false end
          end
        end
        return true
      end

      -- 1. First priority: buffer filetype snippets
      if target_ft and target_ft ~= '' then
        for _, snip in ipairs(luasnip.get_snippets(target_ft) or {}) do
          local key = target_ft .. ':' .. (snip.trigger or '') .. ':' .. (snip.name or '')
          if not seen[key] and is_visible(snip) then
            seen[key] = true
            snip.ft = target_ft
            snip.ft_priority = 1
            table.insert(snippets, snip)
          end
        end
      end

      -- 2. Second priority: global/all snippets
      for _, snip in ipairs((luasnip.get_snippets() and luasnip.get_snippets().all) or {}) do
        local key = 'all:' .. (snip.trigger or '') .. ':' .. (snip.name or '')
        if not seen[key] and is_visible(snip) then
          seen[key] = true
          snip.ft = ''
          snip.ft_priority = 2
          table.insert(snippets, snip)
        end
      end

      local align_1 = 0
      for _, snip in pairs(snippets) do
        align_1 = math.max(align_1, #(snip.name or snip.trigger or ''))
      end
      if ctx and ctx.picker then ctx.picker.align_1 = align_1 end

      local items = {}
      for _, snip in pairs(snippets) do
        local docstring = snip:get_docstring()
        if type(docstring) == 'table' then docstring = table.concat(docstring, '\n') end
        local name = snip.name or snip.trigger or ''
        local description = type(snip.description) == 'table' and table.concat(snip.description, ' ')
          or (snip.description or '')
        description = name == description and '' or description
        table.insert(items, {
          text = name .. ' ' .. description .. ' ' .. (snip.trigger or '') .. ' ' .. (snip.ft or ''),
          name = name,
          description = description,
          trigger = snip.trigger,
          ft = snip.ft,
          ft_priority = snip.ft_priority,
          preview = {
            ft = snip.ft ~= '' and snip.ft or 'markdown',
            text = docstring,
          },
        })
      end
      return items
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      local ok, luasnip = pcall(require, 'luasnip')
      if not ok then return end

      local expand = {}
      luasnip.available(function(snippet)
        if snippet.trigger == item.trigger then table.insert(expand, snippet) end
        return snippet
      end)
      if #expand > 0 then
        vim.cmd('startinsert!')
        vim.defer_fn(function() luasnip.snip_expand(expand[1]) end, 50)
      else
        Snacks.notify.warn('No snippet to expand', { title = 'Snippets' })
      end
    end,
  }, opts or {})
end

function M.open(opts) return Snacks.picker.pick('snippets', opts) end

M.pick = M.open

return setmetatable(M, {
  __call = function(_, opts) return M.open(opts) end,
})
