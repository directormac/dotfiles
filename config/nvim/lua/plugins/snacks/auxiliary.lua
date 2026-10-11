return {
  {
    'emoji.nvim',
    event = 'DeferredUIEnter',
    after = function()
      local ok, emoji = pcall(require, 'emoji')
      if ok then
        local emoji_file = vim.api.nvim_get_runtime_file('lua/data/emojis.json', false)[1]
        local kaomoji_file = vim.api.nvim_get_runtime_file('lua/data/kaomojis.json', false)[1]
        local emoji_cfg = require('emoji.config')
        if emoji_file then
          local dir = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(emoji_file)))
          emoji_cfg.options.plugin_path = dir
          emoji_cfg.paths.emoji = 'lua/data/emojis.json'
          if kaomoji_file then emoji_cfg.paths.kaomoji = 'lua/data/kaomojis.json' end
        end
        emoji.setup({})
      end

      vim.keymap.set(
        'n',
        '<leader>fse',
        '<cmd>lua require("emoji").insert()<CR>',
        { desc = 'Find Emojis (emoji.nvim)' }
      )
    end,
  },
  {
    'snacks-unicode',
    event = 'DeferredUIEnter',
    after = function()
      require('snacks-unicode').setup()

      vim.keymap.set(
        'n',
        '<leader>fsu',
        '<cmd>lua Snacks.picker.unicode()<CR>',
        { desc = 'Find Unicode Symbols (snacks)' }
      )
    end,
  },
  {
    'nvim-float',
    lazy = true,
  },
  {
    'nvim-colorpicker',
    cmd = { 'ColorPicker', 'ColorPickerAtCursor', 'ColorPickerMini', 'ColorHighlight' },
    event = 'DeferredUIEnter',
    before = function() require('lz.n').trigger_load('nvim-float') end,
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
  {
    'nerdy.nvim',
    event = 'DeferredUIEnter',
    after = function()
      require('nerdy').setup({
        picker = 'snacks',
      })
      vim.keymap.set('n', '<leader>fss', '<cmd>Nerdy<CR>', { desc = 'Find Nerd Font Symbols (nerdy)' })
    end,
  },
}
