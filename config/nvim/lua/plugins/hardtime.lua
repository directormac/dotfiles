return {
  {
    'hardtime.nvim',
    event = 'DeferredUIEnter',
    cmd = { 'Hardtime' },
    on_require = { 'hardtime' },
    opts = {
      enabled = true,
      disable_mouse = false,
      max_time = 1000,
      max_count = 3,
      resetting_keys = {
        ['1'] = { 'n', 'v' },
        ['2'] = { 'n', 'v' },
        ['3'] = { 'n', 'v' },
        ['4'] = { 'n', 'v' },
        ['5'] = { 'n', 'v' },
        ['6'] = { 'n', 'v' },
        ['7'] = { 'n', 'v' },
        ['8'] = { 'n', 'v' },
        ['9'] = { 'n', 'v' },
        ['c'] = { 'n' },
        ['C'] = { 'n' },
        ['d'] = { 'n' },
        ['x'] = { 'n' },
        ['X'] = { 'n' },
        ['y'] = { 'n' },
        ['Y'] = { 'n' },
        ['p'] = { 'n' },
        ['P'] = { 'n' },
      },
      disabled_filetypes = {
        ['qf'] = true,
        ['netrw'] = true,
        ['NvimTree'] = true,
        ['lazy'] = true,
        ['mason'] = true,
        ['oil'] = true,
        ['prompt'] = true,
        ['snacks_dashboard'] = true,
        ['snacks_picker_input'] = true,
        ['snacks_picker_list'] = true,
        ['snacks_picker_preview'] = true,
        ['snacks_layout_box'] = true,
        ['snacks_picker.*'] = true,
        ['snacks_.*'] = true,
      },
    },
    after = function(plugin)
      local ok, hardtime = pcall(require, 'hardtime')
      if not ok then return end
      local cfg = require('hardtime.config')
      if plugin and plugin.opts then
        local opts = vim.deepcopy(plugin.opts)
        if opts.disabled_filetypes then
          local normalized = {}
          for k, v in pairs(opts.disabled_filetypes) do
            if type(k) == 'number' and type(v) == 'string' then
              normalized[v] = true
            else
              normalized[k] = v
            end
          end
          opts.disabled_filetypes = normalized
        end
        cfg.config = vim.tbl_deep_extend('force', cfg.config, opts)
      end
      if not cfg.config.disable_mouse and vim.o.mouse == '' then
        vim.o.mouse = 'a'
      end
      hardtime.enable()
      local fn = hardtime.enable
      local n, v = debug.getupvalue(fn, 2)
      if n == 'opts' and type(v) == 'table' and v.fn then fn = v.fn end
      local _, handler_fn = debug.getupvalue(fn, 6)
      if handler_fn then
        for i = 1, 10 do
          local name, val = debug.getupvalue(handler_fn, i)
          if name == 'should_disable_hardtime' and type(val) == 'function' then
            local orig = val
            debug.setupvalue(handler_fn, i, function()
              if package.loaded['snacks'] and Snacks.picker and #Snacks.picker.get() > 0 then return true end
              return orig()
            end)
            break
          end
        end
      end

      Snacks.toggle({
        id = 'hardtime',
        name = 'Hardtime',
        get = function()
          local ok_ht, ht = pcall(require, 'hardtime')
          return ok_ht and ht.is_plugin_enabled == true
        end,
        set = function(state)
          local ht = require('hardtime')
          if state then
            ht.enable()
          else
            ht.disable()
          end
        end,
      }):map('<leader>tH')
    end,
  },
}
