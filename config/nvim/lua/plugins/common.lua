return {
  {
    'mini.nvim',
    lazy = false,
    after = function(plugin)
      require('mini.icons').setup()
      require('mini.bracketed').setup()

      require('mini.surround').setup({
        mappings = {
          add = 'zsa',
          delete = 'zsd',
          find = 'zsf',
          find_left = 'zsF',
          highlight = 'zsh',
          replace = 'zsr',
          update_n_lines = 'gsn',
        },
      })

      vim.keymap.set('n', 'zsq', function()
        -- Pass an empty target '' with 'i' (inside), which tells mini.surround
        -- to automatically detect and target the closest surrounding pair around the cursor.
        require('mini.surround').replace('i', '', "'")
      end, { desc = 'Replace current surrounding with single quotes' })
    end,
  },
  {
    'nvim-web-devicons',
    on_require = { 'nvim-web-devicons' },
    after = function(plugin) require('nvim-web-devicons').setup() end,
  },
  {
    'plenary.nvim',
    on_require = { 'plenary' },
  },
  {
    'nui.nvim',
    on_require = { 'nui' },
  },
  {
    'nvim-nio',
    on_require = { 'nio' },
  },
  {
    -- Configuration Reference https://github.com/gbprod/yanky.nvim#%EF%B8%8F-configuration
    'yanky.nvim',
    on_require = { 'yanky' },
  },
}
