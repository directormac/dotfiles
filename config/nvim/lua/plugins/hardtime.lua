return {
  {
    'hardtime.nvim',
    event = 'DeferredUIEnter',
    cmd = { 'Hardtime' },
    keys = {
      { '<leader>tH', '<cmd>Hardtime toggle<cr>', desc = 'Toggle Hardtime' },
    },
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
        'qf',
        'netrw',
        'NvimTree',
        'lazy',
        'mason',
        'oil',
        'prompt',
        'snacks_dashboard',
        'snacks_picker_input',
        'snacks_picker_list',
        'snacks_picker_preview',
        'snacks_layout_box',
        ['snacks_picker.*'] = true,
        ['snacks_.*'] = true,
      },
    },
    after = function()
      local ok, hardtime = pcall(require, 'hardtime')
      if not ok then return end
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
    end,
  },
}
