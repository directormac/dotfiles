local M = {}

---@param opts? snacks.picker.Config
function M.snippets(opts)
  return Snacks.picker.files(vim.tbl_deep_extend('keep', opts or {}, {
    supports_live = false,
    title = 'Snippets',
    layout = 'vscode',
    preview = 'preview',
    format = function(item, picker)
      local name = Snacks.picker.util.align(item.name, picker.align_1 + 5)
      return {
        { name, item.ft == '' and 'Conceal' or 'DiagnosticWarn' },
        { item.description },
      }
    end,
    finder = function(_, ctx)
      local snippets = {}
      for _, snip in ipairs(require('luasnip').get_snippets().all) do
        snip.ft = ''
        table.insert(snippets, snip)
      end
      for _, snip in ipairs(require('luasnip').get_snippets(vim.bo.ft)) do
        snip.ft = vim.bo.ft
        table.insert(snippets, snip)
      end
      local align_1 = 0
      for _, snip in pairs(snippets) do
        align_1 = math.max(align_1, #snip.name)
      end
      ctx.picker.align_1 = align_1
      local items = {}
      for _, snip in pairs(snippets) do
        local docstring = snip:get_docstring()
        if type(docstring) == 'table' then docstring = table.concat(docstring) end
        local name = snip.name
        local description = table.concat(snip.description)
        description = name == description and '' or description
        table.insert(items, {
          text = name .. ' ' .. description, -- search string
          name = name,
          description = description,
          trigger = snip.trigger,
          ft = snip.ft,
          preview = {
            ft = snip.ft,
            text = docstring,
          },
        })
      end
      return items
    end,
    confirm = function(picker, item)
      picker:close()
      --
      local expand = {}
      require('luasnip').available(function(snippet)
        if snippet.trigger == item.trigger then
          vim.print('match')
          table.insert(expand, snippet)
        end
        return snippet
      end)
      if #expand > 0 then
        vim.cmd(':startinsert!')
        vim.defer_fn(function() require('luasnip').snip_expand(expand[1]) end, 50)
      else
        Snacks.notify.warn('No snippet to expand')
      end
    end,
  }))
end

---@param opts? table Extra picker options
function M.plugins(opts) return require('pickers.lze-plugins').pick(opts) end

return M
