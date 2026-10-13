return {
  {
    'nvim-float',
    load_before = { 'nvim-colorpicker' },
  },
  {
    'nvim-colorpicker',
    cmd = { 'ColorPicker', 'ColorPickerAtCursor', 'ColorPickerMini', 'ColorHighlight' },
    event = 'DeferredUIEnter',
    after = function()
      require('nvim-colorpicker').setup({
        alpha_enabled = true,
        highlight = {
          enable = true,
        },
      })

      vim.keymap.set('n', '<leader>fsc', '<cmd>ColorPicker<CR>', { desc = 'Find Color (colorpicker)' })

      vim.keymap.set('n', '<leader>fsp', function()
        local items = {}
        local ok, colorpicker = pcall(require, 'nvim-colorpicker')
        if ok and colorpicker.presets then
          local presets = colorpicker.presets()
          for _, preset_name in ipairs(presets.get_preset_names()) do
            local preset_colors = presets.get_preset(preset_name)
            if preset_colors then
              for name, hex in pairs(preset_colors) do
                table.insert(items, {
                  text = preset_name .. ' ' .. name .. ' ' .. hex,
                  name = name,
                  hex = hex,
                  preset = preset_name,
                })
              end
            end
          end
        end

        Snacks.picker.pick({
          title = 'Colorpicker Presets',
          items = items,
          format = function(item, _)
            local hl_group = 'SnacksColor' .. item.hex:gsub('#', '')
            pcall(vim.api.nvim_set_hl, 0, hl_group, { fg = item.hex })
            return {
              { '■ ', hl = hl_group },
              { item.name, hl = 'SnacksPickerString' },
              { ' ' .. item.hex, hl = 'SnacksPickerComment' },
              { ' (' .. item.preset .. ')', hl = 'SnacksPickerComment' },
            }
          end,
          confirm = function(picker, item)
            picker:close()
            if item then vim.api.nvim_put({ item.hex }, 'c', true, true) end
          end,
        })
      end, { desc = 'Find Colors (Presets)' })
    end,
  },
}
