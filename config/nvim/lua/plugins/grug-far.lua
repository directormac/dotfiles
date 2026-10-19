-- grug-far.nvim, keybinds adapted from the cookbook:
-- https://github.com/MagicDuck/grug-far.nvim#-cookbook
return {
  {
    'grug-far.nvim',
    -- both commands are registered by plugin/grug-far.lua, so list them both
    -- here for lze to stub them. (only listing GrugFar means :GrugFarWithin
    -- reports "Not an editor command" until the plugin has loaded)
    cmd = { 'GrugFar', 'GrugFarWithin' },
    keys = {
      -- open with a files filter prefilled from the current file extension
      {
        '<leader>sr',
        function()
          local grug = require('grug-far')
          local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          })
        end,
        desc = 'Search and Replace',
        mode = { 'n', 'x' },
      },
      {
        '<leader>far',
        function()
          local grug = require('grug-far')
          local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          })
        end,
        desc = 'Find and Replace',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch with the current word under the cursor as the search string
      {
        '<leader>faw',
        function()
          require('grug-far').open({
            transient = true,
            prefills = { search = vim.fn.expand('<cword>') },
          })
        end,
        desc = 'FAR: search word under cursor',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch, limiting search/replace to current file
      {
        '<leader>faf',
        function()
          require('grug-far').open({
            transient = true,
            prefills = { paths = vim.fn.expand('%') },
          })
        end,
        desc = 'FAR: Current File',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch with the current visual selection, searching only current file
      {
        '<leader>fav',
        function()
          local grug = require('grug-far')
          local opts = { transient = true, prefills = { paths = vim.fn.expand('%') } }
          local mode = vim.fn.mode()
          local have_selection = mode:find('[vV\22]') ~= nil
            or (vim.fn.visualmode() ~= '' and vim.fn.getpos("'<")[2] > 0)
          if have_selection then
            grug.with_visual_selection(opts)
          else
            -- no selection yet (e.g. fresh session): just scope the search to the file
            grug.open(opts)
          end
        end,
        desc = 'FAR: search visual selection in current file',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch, limiting search to the current buffer visual selection
      -- range (the :GrugFarWithin behaviour)
      {
        '<leader>fai',
        function()
          require('grug-far').open({
            transient = true,
            visualSelectionUsage = 'operate-within-range',
          })
        end,
        desc = 'FAR: search within range',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch with @/ register value as the search query,
      -- falling back to visual selection
      {
        '<leader>fa/',
        function()
          local search = vim.fn.getreg('/')
          -- surround with \b if "word" search (such as when pressing `*`)
          if search and vim.startswith(search, '\\<') and vim.endswith(search, '\\>') then
            search = '\\b' .. search:sub(3, -3) .. '\\b'
          elseif search and vim.startswith(search, '\\V') then
            search = search:sub(3)
          end
          local inst = require('grug-far').open({
            transient = true,
            prefills = { search = search },
          })
          inst:when_ready(function() inst:goto_input('replacement') end)
        end,
        desc = 'FAR: search using @/ register value',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch, pre-filling with last history entry
      {
        '<leader>fah',
        function()
          ---@type grug.far.OptionsOverride
          local opts = { transient = true }
          local entry = require('grug-far').get_last_history_entry()
          if entry ~= nil then
            opts.prefills = entry
            opts.engine = entry.engine
            opts.replacementInterpreter = entry.replacementInterpreter
          end
          require('grug-far').open(opts)
        end,
        desc = 'FAR: search, pre-filling with last history entry',
        mode = { 'n', 'x' },
      },
      -- cookbook: launch with ast-grep engine
      {
        '<leader>faa',
        function() require('grug-far').open({ transient = true, engine = 'astgrep' }) end,
        desc = 'FAR: search with ast-grep engine',
        mode = { 'n', 'x' },
      },
      -- cookbook: toggle visibility of a particular instance with a fixed title
      {
        '<leader>fat',
        function()
          require('grug-far').toggle_instance({
            instanceName = 'far',
            staticTitle = 'Find and Replace',
          })
        end,
        desc = 'FAR: toggle Find and Replace instance',
        mode = { 'n', 'x' },
      },
      -- cookbook (buffer-local): toggle --fixed-strings flag
      {
        '<leader>fas',
        function()
          local state = unpack(require('grug-far').get_instance(0):toggle_flags({ '--fixed-strings' }))
          vim.notify('grug-far: toggled --fixed-strings ' .. (state and 'ON' or 'OFF'))
        end,
        desc = 'FAR: toggle --fixed-strings',
        ft = 'grug-far',
      },
      -- cookbook (buffer-local): open a result location and immediately close grug-far
      {
        '<leader>fao',
        function()
          local inst = require('grug-far').get_instance(0)
          inst:open_location()
          inst:close()
        end,
        desc = 'FAR: open location and close',
        ft = 'grug-far',
      },
      -- cookbook (buffer-local): jump back to first input
      {
        '<leader>fag',
        function() require('grug-far').get_instance(0):goto_first_input() end,
        desc = 'FAR: jump back to first input',
        ft = 'grug-far',
      },
      -- cookbook: oil.nvim integration to open search limited to the focused
      -- directory; on re-trigger, only the paths are updated
      {
        '<leader>fad',
        function()
          local prefills = { paths = require('oil').get_current_dir() }
          local grug_far = require('grug-far')
          if not grug_far.has_instance('explorer') then
            grug_far.open({
              instanceName = 'explorer',
              prefills = prefills,
              staticTitle = 'Find and Replace from Explorer',
            })
          else
            local inst = grug_far.get_instance('explorer')
            inst:open()
            -- update the prefills without clearing the search and other fields
            inst:update_input_values(prefills, false)
          end
        end,
        desc = 'FAR: search current directory',
        ft = 'oil',
      },
    },
    opts = {
      engine = 'ripgrep',
    },
  },
}
