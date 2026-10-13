return {
  'snacks.nvim',
  keys = {
    { '<leader>uD', function() Snacks.dashboard.open() end, desc = 'Dashboard' },
  },
  opts = {
    ---@type snacks.dashboard.Config
    dashboard = {
      width = 60,
      pane_gap = 4,
      preset = {
        keys = {
          {
            icon = ' ',
            key = 'f',
            desc = 'Find File',
            action = function() require('fff').find_files() end,
          },
          {
            icon = ' ',
            key = 'g',
            desc = 'Find Text',
            action = function() require('fff').live_grep() end,
          },
          {
            icon = ' ',
            key = 'r',
            desc = 'Recent Files',
            action = ":lua Snacks.dashboard.pick('recent', { layout = { hidden = { 'preview' } } })",
          },
          {
            icon = ' ',
            key = 'p',
            desc = 'Projects',
            action = ':lua Snacks.picker.projects()',
          },
          {
            icon = ' ',
            key = 's',
            desc = 'Restore Session',
            action = function() require('persistence').load() end,
          },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
        header = [[
   █████╗ ██████╗ ████████╗██╗███████╗███████╗██╗  ██╗
  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝╚██╗██╔╝
  ███████║██████╔╝   ██║   ██║█████╗  █████╗   ╚███╔╝
  ██╔══██║██╔══██╗   ██║   ██║██╔══╝  ██╔══╝   ██╔██╗
  ██║  ██║██║  ██║   ██║   ██║██║     ███████╗██╔╝╚██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
  ɔɐɯɹoʇɔǝɹᴉp
             
      ]],
      },
      formats = {
        icon = function(item)
          if item.file and (item.icon == 'file' or item.icon == 'directory') then
            return Snacks.dashboard.icon(item.file, item.icon)
          end
          return { item.icon, width = 2, hl = 'icon' }
        end,
        footer = { '%s', align = 'center' },
        header = { '%s', align = 'center' },
        file = function(item, ctx)
          local fname = vim.fn.fnamemodify(item.file, ':~')
          fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
          if #fname > ctx.width then
            local dir = vim.fn.fnamemodify(fname, ':h')
            local file = vim.fn.fnamemodify(fname, ':t')
            if dir and file then
              file = file:sub(-(ctx.width - #dir - 2))
              fname = dir .. '/…' .. file
            end
          end
          local dir, file = fname:match('^(.*)/(.+)$')
          return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
        end,
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        function()
          local nix_count = _G.nixInfo
              and nixInfo.plugins
              and (vim.tbl_count(nixInfo.plugins.lazy or {}) + vim.tbl_count(nixInfo.plugins.start or {}))
            or 0
          local pack_count = 0
          local lockfile = vim.fs.joinpath(vim.fn.stdpath('config'), 'nvim-pack-lock.json')
          local ok, data = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(lockfile), '\n')) end)
          if ok and data and data.plugins then
            pack_count = vim.tbl_count(data.plugins)
          elseif vim.pack and vim.pack.get then
            pack_count = #vim.pack.get()
          end
          local total = nix_count + pack_count
          local ms = _G.__startup_time and string.format('%.2f', (vim.uv.hrtime() - _G.__startup_time) / 1e6) or '0'

          return {
            align = 'center',
            padding = 1,
            text = {
              { '⚡ Loaded ', hl = 'footer' },
              { tostring(total), hl = 'special' },
              { ' plugins (', hl = 'footer' },
              { tostring(nix_count) .. ' nix', hl = 'Constant' },
              { ' · ', hl = 'footer' },
              { tostring(pack_count) .. ' vim.pack', hl = 'Statement' },
              { ') in ', hl = 'footer' },
              { ms .. 'ms', hl = 'special' },
            },
          }
        end,
      },
    },
  },
}
