nixInfo.lze.load({
  {
    'gitsigns.nvim',
    event = 'DeferredUIEnter',

    after = function(plugin)
      require('gitsigns').setup({
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
        signs_staged = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
          end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
      })

      Snacks.toggle({
        name = 'Git Signs',
        get = function() return require('gitsigns.config').config.signcolumn end,
        set = function(state) require('gitsigns').toggle_signs(state) end,
      }):map('<leader>uG')
    end,
  },

  -- {
  --   'gitsigns.nvim',
  --   auto_enable = true,
  --   event = 'DeferredUIEnter',
  --   -- cmd = { "" },
  --   -- ft = "",
  --   -- keys = "",
  --   -- colorscheme = "",
  --   after = function(plugin)
  --     require('gitsigns').setup({
  --       -- See `:help gitsigns.txt`
  --       signs = {
  --         add = { text = '+' },
  --         change = { text = '~' },
  --         delete = { text = '_' },
  --         topdelete = { text = '‾' },
  --         changedelete = { text = '~' },
  --       },
  --       on_attach = function(bufnr)
  --         local gs = package.loaded.gitsigns
  --
  --         local function map(mode, l, r, opts)
  --           opts = opts or {}
  --           opts.buffer = bufnr
  --           vim.keymap.set(mode, l, r, opts)
  --         end
  --
  --         -- Navigation
  --         map({ 'n', 'v' }, ']c', function()
  --           if vim.wo.diff then return ']c' end
  --           vim.schedule(function() gs.next_hunk() end)
  --           return '<Ignore>'
  --         end, { expr = true, desc = 'Jump to next hunk' })
  --
  --         map({ 'n', 'v' }, '[c', function()
  --           if vim.wo.diff then return '[c' end
  --           vim.schedule(function() gs.prev_hunk() end)
  --           return '<Ignore>'
  --         end, { expr = true, desc = 'Jump to previous hunk' })
  --
  --         -- Actions
  --         -- visual mode
  --         map(
  --           'v',
  --           '<leader>hs',
  --           function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
  --           { desc = 'stage git hunk' }
  --         )
  --         map(
  --           'v',
  --           '<leader>hr',
  --           function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
  --           { desc = 'reset git hunk' }
  --         )
  --         -- normal mode
  --         map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
  --         map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
  --         map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
  --         map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
  --         map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
  --         map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
  --         map('n', '<leader>gb', function() gs.blame_line({ full = false }) end, { desc = 'git blame line' })
  --         map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
  --         map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = 'git diff against last commit' })
  --
  --         -- Toggles
  --         map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
  --         map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })
  --
  --         -- Text object
  --         map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
  --       end,
  --     })
  --     vim.cmd([[hi GitSignsAdd guifg=#04de21]])
  --     vim.cmd([[hi GitSignsChange guifg=#83fce6]])
  --     vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
  --   end,
  -- },
})
