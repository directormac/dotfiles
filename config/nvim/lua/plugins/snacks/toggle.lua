local M = {}

M.opts = {
  toggle = {},
}

function M.keys()
  Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
  Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
  Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
  Snacks.toggle.diagnostics():map('<leader>ud')
  Snacks.toggle.line_number():map('<leader>ul')
  Snacks.toggle
    .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map('<leader>uc')
  Snacks.toggle.treesitter():map('<leader>uT')
  Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
  Snacks.toggle.inlay_hints():map('<leader>uh')
  Snacks.toggle.dim():map('<leader>uD')

  local autohover_enabled = false
  Snacks.toggle({
    id = 'autohover',
    name = 'Auto Hover',
    get = function() return autohover_enabled end,
    set = function(state) autohover_enabled = state end,
  }):map('<leader>uK')

  -- Lensline ("linelens") toggle
  Snacks.toggle({
    id = 'lensline',
    name = 'Lensline',
    get = function()
      local ok, lensline = pcall(require, 'lensline')
      return ok and lensline.is_visible()
    end,
    set = function(state)
      local ok, lensline = pcall(require, 'lensline')
      if not ok then
        pcall(function() require('lz.n').load('lensline.nvim') end)
        ok, lensline = pcall(require, 'lensline')
      end
      if ok then
        if state then
          lensline.show()
        else
          lensline.hide()
        end
      end
    end,
  }):map('<leader>ue')

  -- Otter (Embedded LSP / Injections) toggle
  Snacks.toggle({
    id = 'otter',
    name = 'Otter (Embedded LSP)',
    get = function()
      local ok, keeper = pcall(require, 'otter.keeper')
      if not ok then return false end
      return keeper.rafts[vim.api.nvim_get_current_buf()] ~= nil
    end,
    set = function(state)
      local ok, otter = pcall(require, 'otter')
      if not ok then
        pcall(function() require('lz.n').load('otter.nvim') end)
        ok, otter = pcall(require, 'otter')
      end
      if ok then
        local buf = vim.api.nvim_get_current_buf()
        if state then
          vim.b[buf].otter_disabled = false
          otter.activate(nil, true, true)
        else
          vim.b[buf].otter_disabled = true
          otter.deactivate()
        end
      end
    end,
  }):map('<leader>uo')

  Snacks.toggle.profiler():map('<leader>dpp')
  Snacks.toggle.profiler_highlights():map('<leader>dph')

  Snacks.toggle.zoom():map('<leader>wm'):map('<leader>uZ')
  Snacks.toggle.zen():map('<leader>uz')

  Snacks.toggle.indent():map('<leader>ug')
end

return M
