return {
  'snacks.nvim',
  opts = {
    toggle = {
      enable = true,
    },
  },
  after = function()
    Snacks.toggle.animate():map('<leader>ta')
    Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>ts')
    Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>tw')
    Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>tr')
    Snacks.toggle.diagnostics():map('<leader>td')
    Snacks.toggle.line_number():map('<leader>tl')
    Snacks.toggle
      .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
      :map('<leader>tc')
    Snacks.toggle.treesitter():map('<leader>tT')
    Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>tb')
    Snacks.toggle.inlay_hints():map('<leader>th')
    Snacks.toggle.dim():map('<leader>tD')

    Snacks.toggle({
      id = 'autohover',
      name = 'Auto Hover',
      get = function() return vim.g.autohover end,
      set = function(state) vim.g.autohover = state end,
    }):map('<leader>tK')

    Snacks.toggle({
      id = 'auto_format',
      name = 'Auto Format',
      get = function() return vim.g.auto_format ~= false end,
      set = function(state) vim.g.auto_format = state end,
    }):map('<leader>tf')

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
          pcall(Utils.load_with_after, 'lensline.nvim')
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
    }):map('<leader>te')

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
          pcall(Utils.load_with_after, 'otter.nvim')
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
    }):map('<leader>tO')

    Snacks.toggle.profiler():map('<leader>dpp')
    Snacks.toggle.profiler_highlights():map('<leader>dph')

    Snacks.toggle.zoom():map('<leader>wm'):map('<leader>tZ')
    Snacks.toggle.zen():map('<leader>tz')

    Snacks.toggle.indent():map('<leader>tg')
    Snacks.toggle.scroll():map('<leader>tS')
    Snacks.toggle.words():map('<leader>tW')
  end,
}
