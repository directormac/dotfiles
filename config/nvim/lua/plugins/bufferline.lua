return {
  'bufferline.nvim',
  event = 'DeferredUIEnter',
  keys = {

    -- { '<A-1>', function() require('bufferline').go_to(1, true) end, desc = 'Go to first buffer' },
    -- { '<A-2>', function() require('bufferline').go_to(2, true) end, desc = 'Go to first buffer' },
    -- { '<A-3>', function() require('bufferline').go_to(3, true) end, desc = 'Go to first buffer' },
    -- { '<A-4>', function() require('bufferline').go_to(4, true) end, desc = 'Go to first buffer' },
    -- { '<A-5>', function() require('bufferline').go_to(5, true) end, desc = 'Go to first buffer' },
    -- { '<A-6>', function() require('bufferline').go_to(6, true) end, desc = 'Go to first buffer' },

    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
    { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
    { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
    { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
  },
  opts = function()
    return {
      options = {
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = 'nvim_lsp',

        diagnostics_indicator = function(_, _, diag)
          local icons = Utils.icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
            .. (diag.warning and icons.Warn .. diag.warning or '')
          return vim.trim(ret)
        end,
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        show_close_icon = false,
        themable = true,
        indicator = {
          icon = ' ',
          style = 'icon',
        },
        separator_style = { '', '' },
        offsets = {
          { filetype = 'oil' },
          { filetype = 'snacks_layout_box' },
          { filetype = 'snacks_picker_list' },
        },
        name_formatter = function(buf)
          if buf.tabnr then
            local ok, name = pcall(vim.api.nvim_tabpage_get_var, buf.tabnr, 'name')
            if ok and name then return name end
          end
        end,
      },
      highlights = {
        indicator_selected = { fg = '#cba6f7', bg = 'none' },
      },
    }
  end,
  after = function()
    -- Patch bufferline.groups persist_pinned_buffers against invalid buffer IDs
    local ok, groups = pcall(require, 'bufferline.groups')
    if ok and groups.add_element then
      local fn = groups.add_element
      local n, v = debug.getupvalue(fn, 2)
      if n == 'opts' and type(v) == 'table' and v.fn then fn = v.fn end
      local _, persist_fn = debug.getupvalue(fn, 3)
      if persist_fn then
        local _, group_state = debug.getupvalue(persist_fn, 1)
        local _, pinned_id = debug.getupvalue(persist_fn, 2)
        local _, pinned_key = debug.getupvalue(persist_fn, 4)
        if group_state and pinned_id and pinned_key then
          local patched_persist = function()
            local pinned = {}
            for buf, grp in pairs(group_state.manual_groupings) do
              if grp == pinned_id then
                if vim.api.nvim_buf_is_valid(buf) then
                  table.insert(pinned, vim.api.nvim_buf_get_name(buf))
                else
                  group_state.manual_groupings[buf] = nil
                end
              end
            end
            if #pinned == 0 then
              vim.g[pinned_key] = ''
            else
              vim.g[pinned_key] = table.concat(pinned, ',')
            end
          end
          debug.setupvalue(fn, 3, patched_persist)

          local rfn = groups.remove_element
          local rn, rv = debug.getupvalue(rfn, 2)
          if rn == 'opts' and type(rv) == 'table' and rv.fn then rfn = rv.fn end
          debug.setupvalue(rfn, 5, patched_persist)
        end
      end
    end

    vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
      group = vim.api.nvim_create_augroup('bufferline_pinned_cleanup', { clear = true }),
      callback = function(args)
        local g_ok, g = pcall(require, 'bufferline.groups')
        if g_ok and g.remove_id_from_manual_groupings then g.remove_id_from_manual_groupings(args.buf) end
      end,
    })
  end,
}
