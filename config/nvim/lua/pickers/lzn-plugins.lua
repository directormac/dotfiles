local M = {}

-- Helper to extract clean version strings from Nix store path
local function parse_plugin_version(path)
  if not path or path == '' then return nil end
  local base = vim.fs.basename(path)
  local pkg = base:match('^%w+-(.+)$') or base
  pkg = pkg:gsub('^vimplugin%-', ''):gsub('^luajit2%.1%-', '')
  local ver = pkg:match('-(%d+[%w%._-]*)$') or pkg:match('-(unstable[%w%._-]*)$') or pkg:match('-(scm[%w%._-]*)$')
  if not ver then return nil end
  local date = ver:match('(%d%d%d%d%-%d%d%-%d%d)')
  if date then
    local v = ver:match('^(%d+%.%d+%.%d+)')
    if v then return 'v' .. v .. ' (' .. date .. ')' end
    return 'git ' .. date
  end
  return 'v' .. ver
end

-- Helper to extract triggers from lz.n spec
local function get_plugin_triggers(name)
  local spec = package.loaded['lz.n'] and require('lz.n').lookup(name)
  if not spec then return nil end
  local triggers = {
    events = {},
    ft = {},
    cmds = {},
    keys = {},
  }
  if spec.cmd then
    local cmds = type(spec.cmd) == 'table' and spec.cmd or { spec.cmd }
    for _, c in ipairs(cmds) do
      table.insert(triggers.cmds, c)
    end
  end
  if spec.keys then
    for _, k in ipairs(spec.keys) do
      local lhs = k.lhs or k[1]
      local desc = k.desc or ''
      if lhs then table.insert(triggers.keys, { lhs = lhs, desc = desc }) end
    end
  end
  if spec.event then
    for _, ev in ipairs(spec.event) do
      if ev.event == 'FileType' then
        table.insert(triggers.ft, ev.pattern or '')
      elseif ev.pattern and ev.pattern ~= '' then
        table.insert(triggers.events, ev.pattern)
      elseif ev.event then
        table.insert(triggers.events, ev.event)
      end
    end
  end
  if spec.ft then
    local fts = type(spec.ft) == 'table' and spec.ft or { spec.ft }
    for _, f in ipairs(fts) do
      table.insert(triggers.ft, f)
    end
  end
  return triggers
end

-- Helper to summarize triggers for one-line display
local function format_trigger_summary(triggers)
  if not triggers then return '' end
  local parts = {}
  if #triggers.ft > 0 then table.insert(parts, 'ft:' .. table.concat(triggers.ft, ',')) end
  if #triggers.cmds > 0 then table.insert(parts, 'cmd:' .. table.concat(triggers.cmds, ',')) end
  if #triggers.events > 0 then table.insert(parts, 'event:' .. table.concat(triggers.events, ',')) end
  if #triggers.keys > 0 then
    local key_lhs = {}
    for _, k in ipairs(triggers.keys) do
      table.insert(key_lhs, k.lhs)
    end
    table.insert(parts, 'keys:' .. table.concat(key_lhs, ' '))
  end
  return table.concat(parts, ' | ')
end

--- Open Snacks picker for Nix & lz.n managed plugins
---@param opts? table Extra picker options to forward to Snacks.picker.pick
function M.pick(opts)
  local rtp_names = {}
  for _, path in ipairs(vim.opt.rtp:get()) do
    rtp_names[vim.fs.basename(path)] = true
  end

  local function is_plugin_decl(line, name)
    local escaped = vim.pesc(name)
    return line:match('^%s*[\'"]' .. escaped .. '[\'"]') ~= nil or line:match('{%s*[\'"]' .. escaped .. '[\'"]') ~= nil
  end

  local plugins = nixInfo(nil, 'plugins') or {}
  local config_dir = vim.fn.stdpath('config')
  local spec_files = vim.fn.glob(config_dir .. '/lua/plugins/**/*.lua', false, true)
  if #spec_files == 0 and Util and Util.root then
    spec_files = vim.fn.glob(Util.root() .. '/config/nvim/lua/plugins/**/*.lua', false, true)
  end

  local plugin_to_spec = {}
  for _, file in ipairs(spec_files) do
    local lines = vim.fn.readfile(file)
    for lnum, line in ipairs(lines) do
      for name in pairs(plugins.lazy or {}) do
        if not plugin_to_spec[name] and is_plugin_decl(line, name) then
          local start_l = math.max(1, lnum)
          local end_l = math.min(#lines, lnum + 18)
          local snippet = {}
          for i = start_l, end_l do
            table.insert(snippet, lines[i])
          end
          plugin_to_spec[name] = { file = file, line = lnum, snippet = snippet }
        end
      end
      for name in pairs(plugins.start or {}) do
        if not plugin_to_spec[name] and is_plugin_decl(line, name) then
          local start_l = math.max(1, lnum)
          local end_l = math.min(#lines, lnum + 18)
          local snippet = {}
          for i = start_l, end_l do
            table.insert(snippet, lines[i])
          end
          plugin_to_spec[name] = { file = file, line = lnum, snippet = snippet }
        end
      end
    end
  end

  local items = {}

  local function add_item(name, path, status, loaded)
    local spec_info = plugin_to_spec[name]
    local version = parse_plugin_version(path)
    local triggers = get_plugin_triggers(name)
    local trigger_summary = format_trigger_summary(triggers)
    local spec_basename = spec_info and vim.fs.basename(spec_info.file) or ''

    local search_terms = {
      name,
      status,
      loaded and 'loaded' or 'lazy',
      version or '',
      trigger_summary,
      spec_basename,
    }
    if triggers then
      for _, f in ipairs(triggers.ft) do
        table.insert(search_terms, f)
      end
      for _, c in ipairs(triggers.cmds) do
        table.insert(search_terms, c)
      end
      for _, e in ipairs(triggers.events) do
        table.insert(search_terms, e)
      end
      for _, k in ipairs(triggers.keys) do
        table.insert(search_terms, k.lhs)
        if k.desc and k.desc ~= '' then table.insert(search_terms, k.desc) end
      end
    end

    table.insert(items, {
      name = name,
      path = path,
      status = status,
      loaded = loaded,
      version = version,
      triggers = triggers,
      trigger_summary = trigger_summary,
      text = table.concat(search_terms, ' '),
      file = spec_info and spec_info.file or path,
      pos = spec_info and { spec_info.line, 1 } or nil,
      spec_file = spec_info and spec_info.file or nil,
      spec_snippet = spec_info and spec_info.snippet or nil,
    })
  end

  for name, path in pairs(plugins.start or {}) do
    add_item(name, path, 'start', true)
  end

  for name, path in pairs(plugins.lazy or {}) do
    local loaded = rtp_names[name] == true
    add_item(name, path, loaded and 'loaded' or 'lazy', loaded)
  end

  table.sort(items, function(a, b)
    if a.loaded ~= b.loaded then return a.loaded end
    return a.name < b.name
  end)

  local picker_opts = vim.tbl_deep_extend('force', {
    title = 'Plugins',
    items = items,
    format = function(item, _)
      local icon = item.status == 'start' and '◆ ' or (item.loaded and '● ' or '○ ')
      local icon_hl = item.status == 'start' and 'DiagnosticInfo'
        or (item.loaded and 'DiagnosticOk' or 'DiagnosticWarn')
      local status_label = '[' .. item.status .. ']'
      local status_hl = item.status == 'start' and 'DiagnosticInfo'
        or (item.loaded and 'DiagnosticOk' or 'SnacksPickerComment')

      local ret = {
        { icon, hl = icon_hl },
        { string.format('%-28s', item.name), hl = 'SnacksPickerLabel' },
      }

      if item.version and item.version ~= '' then
        ret[#ret + 1] = { string.format('%-18s', item.version), hl = 'SnacksPickerComment' }
      else
        ret[#ret + 1] = { string.format('%-18s', ''), hl = 'SnacksPickerComment' }
      end

      ret[#ret + 1] = { string.format('%-9s', status_label), hl = status_hl }

      if item.trigger_summary and item.trigger_summary ~= '' then
        ret[#ret + 1] = { ' ' .. item.trigger_summary, hl = 'Special' }
      end

      if item.spec_file then
        ret[#ret + 1] = {
          ' 󰈙 ' .. vim.fn.fnamemodify(item.spec_file, ':t') .. ':' .. (item.pos and item.pos[1] or 1),
          hl = 'SnacksPickerComment',
        }
      end

      return ret
    end,
    preview = function(ctx)
      local item = ctx.item
      if not item then return end
      ctx.preview:reset()

      local title = item.name .. (item.version and (' (' .. item.version .. ')') or '')
      ctx.preview:set_title(title)

      local lines = {}
      local function add(l) table.insert(lines, l) end

      local icon = item.status == 'start' and '◆' or (item.loaded and '●' or '○')
      local status_text = item.status == 'start' and 'Start Plugin' or (item.loaded and 'Loaded' or 'Lazy (unloaded)')

      add('# ' .. item.name .. '  ' .. icon .. ' ' .. status_text)
      add('')
      add('- **Status**: `' .. item.status .. '`' .. (item.loaded and ' (currently in runtime)' or ' (deferred)'))
      if item.version then add('- **Version**: `' .. item.version .. '`') end
      if item.spec_file then
        add(
          '- **Spec File**: `'
            .. vim.fn.fnamemodify(item.spec_file, ':.')
            .. ':'
            .. (item.pos and item.pos[1] or 1)
            .. '`'
        )
      end
      if item.path then add('- **Nix Store**: `' .. item.path .. '`') end

      if item.triggers then
        local has_trig = #item.triggers.events > 0
          or #item.triggers.ft > 0
          or #item.triggers.cmds > 0
          or #item.triggers.keys > 0
        if has_trig then
          add('')
          add('### Triggers')
          if #item.triggers.events > 0 then
            add('- **Events**: `' .. table.concat(item.triggers.events, '`, `') .. '`')
          end
          if #item.triggers.ft > 0 then add('- **Filetypes**: `' .. table.concat(item.triggers.ft, '`, `') .. '`') end
          if #item.triggers.cmds > 0 then
            add('- **Commands**: `' .. table.concat(item.triggers.cmds, '`, `') .. '`')
          end
          if #item.triggers.keys > 0 then
            add('- **Keymaps**:')
            for _, k in ipairs(item.triggers.keys) do
              local desc = (k.desc and k.desc ~= '') and (' — ' .. k.desc) or ''
              add('  - `' .. k.lhs .. '`' .. desc)
            end
          end
        end
      end

      if item.spec_snippet and #item.spec_snippet > 0 then
        add('')
        add('### Config Spec (`' .. vim.fn.fnamemodify(item.spec_file, ':t') .. '`)')
        add('```lua')
        for _, s in ipairs(item.spec_snippet) do
          add(s)
        end
        add('```')
      end

      add('')
      add('---')
      add(
        '*Actions: `<CR>` jump to spec | `<C-l>` trigger load | `<C-o>` browse store files | `<C-h>` help | `<C-r>` README*'
      )

      ctx.preview:set_lines(lines)
      ctx.preview:highlight({ ft = 'markdown' })
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      if item.spec_file and item.pos then
        vim.cmd.edit(item.spec_file)
        vim.api.nvim_win_set_cursor(0, item.pos)
      elseif item.path then
        Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' })
      end
    end,
    actions = {
      browse_store = function(picker, item)
        picker:close()
        if item and item.path then Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' }) end
      end,
      toggle_load = function(picker, item)
        if item and not item.loaded then
          require('lz.n').trigger_load(item.name)
          item.loaded = true
          item.status = 'loaded'
          item.text = item.name .. ' loaded ' .. (item.version or '') .. ' ' .. item.trigger_summary
          Snacks.notify('Loaded ' .. item.name, { title = 'Plugins' })
          picker:find()
        end
      end,
      open_readme = function(picker, item)
        if item and item.path then
          local readme = item.path .. '/README.md'
          if vim.uv.fs_stat(readme) then
            picker:close()
            vim.cmd.edit(readme)
          else
            Snacks.notify('No README.md found in ' .. item.name, { title = 'Plugins', level = 'warn' })
          end
        end
      end,
      open_help = function(picker, item)
        if item then
          picker:close()
          local ok = pcall(vim.cmd, 'help ' .. item.name)
          if not ok then Snacks.notify('No help tags for ' .. item.name, { title = 'Plugins', level = 'warn' }) end
        end
      end,
    },
    win = {
      input = {
        keys = {
          ['<C-o>'] = { 'browse_store', desc = 'Browse store files' },
          ['<C-l>'] = { 'toggle_load', desc = 'Trigger load plugin' },
          ['<C-r>'] = { 'open_readme', desc = 'Open README.md' },
          ['<C-h>'] = { 'open_help', desc = 'Open help page' },
        },
      },
    },
  }, opts or {})

  Snacks.picker.pick(picker_opts)
end

M.open = M.pick

return setmetatable(M, {
  __call = function(_, opts) return M.pick(opts) end,
})
