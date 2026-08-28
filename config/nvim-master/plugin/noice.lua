-- vim.pack.add({ 'https://github.com/MunifTanjim/nui.nvim' })
-- vim.pack.add({
--   'https://github.com/folke/noice.nvim',
-- })
--
-- vim.pack.add({
--   'https://github.com/rcarriga/nvim-notify',
-- })

-- Reference https://github.com/folke/noice.nvim#%EF%B8%8F-configuration

require('noice').setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- cmdline = {
  --   view = 'cmdline', -- Bottom cmdline only
  --   format = {
  --     lua = false, -- Disable lua mode icon/padding completely
  --   },
  -- },
  routes = {
    {
      filter = {
        event = 'msg_showmode',
      },
      view = 'notify',
    },
  },
  views = {
    cmdline_popup = {
      position = {
        row = 5,
        col = '50%',
      },
      size = {
        width = 60,
        height = 'auto',
      },
    },
    popupmenu = {
      relative = 'editor',
      position = {
        row = 8,
        col = '50%',
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = 'rounded',
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
      },
    },
  },

  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})
