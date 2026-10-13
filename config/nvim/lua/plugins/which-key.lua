return {
  {
    'which-key.nvim',
    event = 'DeferredUIEnter',
    ---@class wk.Opts
    opts = {
      preset = 'helix',
      ---@param mapping wk.Mapping
      filter = function(mapping)
        -- Filter Hapoon keys
        if mapping.desc and mapping.desc:match('Harpoon to File') then return false end
        -- example to exclude mappings without a description
        -- return mapping.desc and mapping.desc ~= ""
        return true
      end,
      ---@type (string|wk.Sorter)[]
      --- Mappings are sorted using configured sorters and natural sort of the keys
      --- Available sorters:
      --- * local: buffer-local mappings first
      --- * order: order of the items (Used by plugins like marks / registers)
      --- * group: groups last
      --- * alphanum: alpha-numerical first
      --- * mod: special modifier keys last
      --- * manual: the order the mappings were added
      --- * case: lower-case first
      sort = { 'manual', 'local', 'order', 'group', 'alphanum', 'mod' },
      icons = {
        ---@type wk.IconRule[]
        rules = {
          { pattern = 'harpoon', icon = '󰛢 ', color = 'green' },
          { pattern = 'oil', icon = '󱧫 ', color = 'blue' },
        },
      },
      --@type wk.Spec
      spec = {
        {
          mode = { 'n', 'x' },
          { '<leader><tab>', group = 'Tabs' },
          { '<leader>c', group = 'Code' },
          { '<leader>d', group = 'Debug' },
          { '<leader>dp', group = 'Profiler' },
          { '<leader>f', group = 'Find' },
          { '<leader>g', group = 'Git' },
          { '<leader>gh', group = 'Hunks' },
          { '<leader>q', group = 'Quit/session' },
          { '<leader>s', group = 'Search' },
          { '<leader>u', group = 'Ui' },
          { '<leader>x', group = 'Diagnostics/quickfix' },
          { '<leader>t', group = 'Toggle' },
          { '[', group = 'prev' },
          { ']', group = 'next' },
          { 'g', group = 'goto' },
          { 'gs', group = 'surround' },
          { 'z', group = 'fold' },
          {
            '<leader>b',
            group = 'buffer',
            expand = function() return require('which-key.extras').expand.buf() end,
          },
          {
            '<leader>w',
            group = 'windows',
            proxy = '<c-w>',
            expand = function() return require('which-key.extras').expand.win() end,
          },
          -- better descriptions
          { 'gx', desc = 'Open with system app' },
        },

        { '<leader>o', group = 'Oil Explorer' },
      },
    },
    keys = {
      {
        '<c-w><space>',
        function() require('which-key').show({ keys = '<c-w>', loop = true }) end,
        desc = 'Window Hydra Mode (which-key)',
      },
      {
        '<leader>?',
        function() Snacks.picker.keymaps() end,
        desc = 'Search Keybindings',
      },
    },
  },
}
