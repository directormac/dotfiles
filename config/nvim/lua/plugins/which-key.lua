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
          { pattern = '^harpoon', icon = '󰛢 ', color = 'green' },
          { pattern = '^oil', icon = '󱧫 ', color = 'blue' },
          { pattern = '^org', icon = ' ', color = 'green' },
          { pattern = 'replace', icon = ' ', color = 'cyan' },
          { pattern = '^far', icon = ' ', color = 'cyan' },
          { pattern = '^surround', icon = ' ' },
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
          { '<leader>fa', group = 'Find and Replace(FAR)', icon = ' ' },
          { 'gs', group = 'Surround', icon = ' ' },
          { '<leader>g', group = 'Git' },
          { '<leader>gh', group = 'Hunks' },
          { '<leader>q', group = 'Quit/session' },
          { '<leader>s', group = 'Search' },
          { '<leader>u', group = 'Ui' },
          { '<leader>x', group = 'Diagnostics / Quickfix (Trouble)' },
          { '<leader>t', group = 'Toggle' },
          { '[', group = 'prev' },
          { ']', group = 'next' },
          { 'g', group = 'goto' },
          { 'z', group = 'fold' },
          { 'zq', group = 'Multicursor (motion)' },
          { 'zq*', desc = 'Cursor on word matches to EOF' },
          { 'zqgn', desc = 'Cursor on search matches to EOF' },
          { 'zqw', desc = 'Cursor on each word to EOF' },
          { 'zqj', desc = 'Cursor on each line below' },
          { 'Q', desc = 'Toggle multicursor at cursor' },
          { 'q=', desc = 'Toggle multicursor follow mode' },
          { 'gQ', desc = 'Restore previous multicursors' },
          { 'g<C-a>', desc = 'Multicursor sequential numbers' },
          { ']C', desc = 'Next multicursor' },
          { '[C', desc = 'Previous multicursor' },
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

        { '<leader>o', group = 'Org' },
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
    after = function()
      -- Show recorded macros on `@`, like `"` shows registers and ` marks.
      -- Registers with content get a real keymap whose desc is the macro
      -- body, so which-key lists them with a preview; empty ones are
      -- removed so native behavior (error beep) is untouched. The `@reg`
      -- rhs is non-recursive, so execution (and `@@`) works as usual.
      local function sync_macros()
        for _, range in ipairs({ { 65, 90 }, { 97, 122 } }) do -- A-Z, a-z
          for code = range[1], range[2] do
            local reg = vim.fn.nr2char(code)
            local macro = vim.fn.getreg(reg)
            if macro ~= '' then
              local shown = vim.fn.strcharpart(macro, 0, 80)
              local truncated = vim.fn.strchars(macro) > 80
              local desc = shown:gsub('[\r\n]+', '⏎'):gsub('^%s+', ''):gsub('%s+$', '')
              if truncated then desc = desc .. '…' end
              vim.keymap.set('n', '@' .. reg, '@' .. reg, { desc = desc, silent = true })
            else
              pcall(vim.keymap.del, 'n', '@' .. reg)
            end
          end
        end
      end

      local group = vim.api.nvim_create_augroup('WhichKeyMacros', { clear = true })
      vim.api.nvim_create_autocmd('RecordingEnter', { group = group, callback = sync_macros })
      vim.api.nvim_create_autocmd('RecordingLeave', { group = group, callback = sync_macros })
    end,
  },
}
