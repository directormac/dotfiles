local M = {}

local update_cache = {}
local cached_specs, cached_plugin_to_spec

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

-- Helper to extract triggers from a resolved plugin spec
local function extract_triggers_from_spec(spec)
  if not spec or type(spec) ~= 'table' then return nil end

  local triggers = {
    events = {},
    ft = {},
    cmds = {},
    keys = {},
    load_before = {},
    dep_of = {},
    after = {},
  }

  -- Commands
  if spec.cmd then
    local cmds = type(spec.cmd) == 'table' and spec.cmd or { spec.cmd }
    for _, c in ipairs(cmds) do
      if type(c) == 'string' and c ~= '' then table.insert(triggers.cmds, c) end
    end
  end

  -- Keys
  if spec.keys then
    local raw_keys = type(spec.keys) == 'table' and spec.keys or { spec.keys }
    for _, k in ipairs(raw_keys) do
      if type(k) == 'string' and k ~= '' then
        table.insert(triggers.keys, { lhs = k, desc = '' })
      elseif type(k) == 'table' then
        local lhs = k.lhs or k[1]
        local desc = k.desc or ''
        if lhs and type(lhs) == 'string' then table.insert(triggers.keys, { lhs = lhs, desc = desc }) end
      end
    end
  end

  -- Events (handles string, list of strings, or table of event objects)
  if spec.event then
    local raw_events = type(spec.event) == 'table' and spec.event or { spec.event }
    for _, ev in ipairs(raw_events) do
      if type(ev) == 'string' and ev ~= '' then
        table.insert(triggers.events, ev)
      elseif type(ev) == 'table' then
        if ev.event == 'FileType' then
          if ev.pattern and ev.pattern ~= '' then table.insert(triggers.ft, ev.pattern) end
        elseif ev.pattern and ev.pattern ~= '' then
          table.insert(triggers.events, ev.pattern)
        elseif ev.event and ev.event ~= '' then
          table.insert(triggers.events, ev.event)
        end
      end
    end
  end

  -- Filetypes
  if spec.ft then
    local fts = type(spec.ft) == 'table' and spec.ft or { spec.ft }
    for _, f in ipairs(fts) do
      if type(f) == 'string' and f ~= '' then table.insert(triggers.ft, f) end
    end
  end

  -- Load before
  if spec.load_before then
    local befores = type(spec.load_before) == 'table' and spec.load_before or { spec.load_before }
    for _, b in ipairs(befores) do
      if type(b) == 'string' and b ~= '' then table.insert(triggers.load_before, b) end
    end
  end

  -- Dep of
  if spec.dep_of then
    local deps = type(spec.dep_of) == 'table' and spec.dep_of or { spec.dep_of }
    for _, d in ipairs(deps) do
      if type(d) == 'string' and d ~= '' then table.insert(triggers.dep_of, d) end
    end
  end

  -- After (when string/table of plugin names, not hook function)
  if spec.after and type(spec.after) ~= 'function' then
    local afters = type(spec.after) == 'table' and spec.after or { spec.after }
    for _, a in ipairs(afters) do
      if type(a) == 'string' and a ~= '' then table.insert(triggers.after, a) end
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
  if #triggers.load_before > 0 then table.insert(parts, 'before:' .. table.concat(triggers.load_before, ',')) end
  if #triggers.dep_of > 0 then table.insert(parts, 'dep_of:' .. table.concat(triggers.dep_of, ',')) end
  if #triggers.after > 0 then table.insert(parts, 'after:' .. table.concat(triggers.after, ',')) end
  return table.concat(parts, ' | ')
end

-- Helper to scan config/nvim/lua/plugins for specs and line numbers
local function load_specs_and_locations(plugins)
  local config_dir = vim.fn.stdpath('config')
  local spec_files = vim.fn.glob(config_dir .. '/lua/plugins/**/*.lua', false, true)
  if #spec_files == 0 and Utils and Utils.root then
    spec_files = vim.fn.glob(Utils.root() .. '/config/nvim/lua/plugins/**/*.lua', false, true)
  end

  local specs_cache = {}
  local plugin_to_spec = {}

  local function is_plugin_decl(line, name)
    local escaped = vim.pesc(name)
    return line:match('^%s*[\'"]' .. escaped .. '[\'"]') ~= nil
      or line:match('{%s*[\'"]' .. escaped .. '[\'"]') ~= nil
      or line:match('name%s*=%s*[\'"]' .. escaped .. '[\'"]') ~= nil
  end

  local function add_spec_to_cache(spec)
    if type(spec) ~= 'table' then return end
    local name = spec.name or (type(spec[1]) == 'string' and spec[1])
    if name then
      specs_cache[name] = spec
    else
      for _, item in ipairs(spec) do
        add_spec_to_cache(item)
      end
    end
  end

  for _, file in ipairs(spec_files) do
    local modname = file:match('.*/lua/(plugins/.*)%.lua$') or file:match('.*/lua/(plugins/.*)/init%.lua$')
    if modname then
      modname = modname:gsub('/', '.')
      local ok, mod = pcall(require, modname)
      if ok and type(mod) == 'table' then add_spec_to_cache(mod) end
    end

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

  return specs_cache, plugin_to_spec
end

local function get_specs_and_locations(plugins)
  if not cached_specs then
    cached_specs, cached_plugin_to_spec = load_specs_and_locations(plugins)
  end
  return cached_specs, cached_plugin_to_spec
end

function M.get_items()
  local rtp_names = {}
  for _, path in ipairs(vim.opt.rtp:get()) do
    rtp_names[vim.fs.basename(path)] = true
  end

  local plugins = (nixInfo and nixInfo(nil, 'plugins')) or {}
  local specs_cache, plugin_to_spec = get_specs_and_locations(plugins)

  local function get_plugin_spec(name)
    -- 1. Try lze live state (if pending)
    if nixInfo and nixInfo.lze and nixInfo.lze.state then
      local ok, s = pcall(function() return nixInfo.lze.state[name] end)
      if ok and type(s) == 'table' then return s end
    elseif package.loaded['lze'] and require('lze').state then
      local ok, s = pcall(function() return require('lze').state[name] end)
      if ok and type(s) == 'table' then return s end
    end
    -- 2. Fall back to specs_cache loaded from lua/plugins
    if specs_cache[name] then return specs_cache[name] end
    return nil
  end

  local function is_plugin_loaded(name)
    if rtp_names[name] == true or package.loaded[name] ~= nil then return true end
    if nixInfo and nixInfo.lze and nixInfo.lze.state then
      local ok, res = pcall(function() return nixInfo.lze.state(name) end)
      if ok and res == false then return true end
    elseif package.loaded['lze'] and require('lze').state then
      local ok, res = pcall(function() return require('lze').state(name) end)
      if ok and res == false then return true end
    end
    return false
  end

  local seen = {}
  local items = {}

  local function add_item(name, path, status, loaded)
    if seen[name] then return end
    seen[name] = true

    local spec_info = plugin_to_spec[name]
    local meta = nixInfo and nixInfo(nil, 'info', 'plugins_meta', name)
    local version = (meta and meta.version) or parse_plugin_version(path)
    local repo = meta and meta.repo or nil
    local rev = meta and meta.rev or nil
    local spec = get_plugin_spec(name)
    local triggers = extract_triggers_from_spec(spec)
    local trigger_summary = format_trigger_summary(triggers)
    local spec_basename = spec_info and vim.fs.basename(spec_info.file) or ''

    local search_terms = {
      name,
      status,
      loaded and 'loaded' or 'lazy',
      version or '',
      repo or '',
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
      for _, b in ipairs(triggers.load_before) do
        table.insert(search_terms, b)
      end
      for _, d in ipairs(triggers.dep_of) do
        table.insert(search_terms, d)
      end
      for _, a in ipairs(triggers.after) do
        table.insert(search_terms, a)
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
      repo = repo,
      rev = rev,
      triggers = triggers,
      trigger_summary = trigger_summary,
      text = table.concat(search_terms, ' '),
      file = spec_info and spec_info.file or path,
      pos = spec_info and { spec_info.line, 1 } or nil,
      spec_file = spec_info and spec_info.file or nil,
      spec_snippet = spec_info and spec_info.snippet or nil,
    })
  end

  for name, path in pairs(plugins.lazy or {}) do
    local loaded = is_plugin_loaded(name)
    add_item(name, path, loaded and 'loaded' or 'lazy', loaded)
  end

  for name, path in pairs(plugins.start or {}) do
    add_item(name, path, 'start', true)
  end

  table.sort(items, function(a, b)
    if a.loaded ~= b.loaded then return a.loaded end
    return a.name < b.name
  end)

  return items
end

function M.format(item, _)
  local icon = item.status == 'start' and '◆ ' or (item.loaded and '● ' or '○ ')
  local icon_hl = item.status == 'start' and 'DiagnosticInfo' or (item.loaded and 'DiagnosticOk' or 'DiagnosticWarn')
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

  local uc = update_cache[item.name]
  if uc then
    if uc.status == 'checking' then
      ret[#ret + 1] = { ' [checking...]', hl = 'SnacksPickerComment' }
    elseif uc.status == 'up-to-date' then
      ret[#ret + 1] = { ' [✓ up-to-date]', hl = 'DiagnosticOk' }
    elseif uc.status == 'update-available' then
      ret[#ret + 1] = { ' [↑ ' .. (uc.remote_sha or 'new') .. ']', hl = 'DiagnosticWarn' }
    elseif uc.status == 'error' then
      ret[#ret + 1] = { ' [✗ error]', hl = 'DiagnosticError' }
    end
  end

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
end

function M.preview(ctx)
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
  if item.repo then
    add('- **Repository**: [https://github.com/' .. item.repo .. '](https://github.com/' .. item.repo .. ')')
  end
  if item.rev then add('- **Pinned Rev**: `' .. item.rev .. '`') end

  local uc = update_cache[item.name]
  if uc then
    if uc.status == 'checking' then
      add('- **Update Check**: *checking upstream GitHub...*')
    elseif uc.status == 'up-to-date' then
      add('- **Update Check**: `✓ up-to-date` (' .. (uc.remote_sha or '') .. ')')
    elseif uc.status == 'update-available' then
      local p_rev = item.rev and item.rev:sub(1, 7) or 'pinned'
      add('- **Update Check**: `↑ update available` (' .. p_rev .. ' -> `' .. (uc.remote_sha or '') .. '`)')
    elseif uc.status == 'error' then
      add('- **Update Check**: `✗ error`: ' .. (uc.err or 'unknown'))
    end
  else
    if item.repo then add('- **Update Check**: *press `<A-u>` to check for updates*') end
  end

  if item.spec_file then
    add(
      '- **Spec File**: `' .. vim.fn.fnamemodify(item.spec_file, ':.') .. ':' .. (item.pos and item.pos[1] or 1) .. '`'
    )
  end
  if item.path then add('- **Nix Store**: `' .. item.path .. '`') end

  if item.triggers then
    local has_trig = #item.triggers.events > 0
      or #item.triggers.ft > 0
      or #item.triggers.cmds > 0
      or #item.triggers.keys > 0
      or #item.triggers.load_before > 0
      or #item.triggers.dep_of > 0
      or #item.triggers.after > 0
    if has_trig then
      add('')
      add('### Triggers')
      if #item.triggers.events > 0 then add('- **Events**: `' .. table.concat(item.triggers.events, '`, `') .. '`') end
      if #item.triggers.ft > 0 then add('- **Filetypes**: `' .. table.concat(item.triggers.ft, '`, `') .. '`') end
      if #item.triggers.cmds > 0 then add('- **Commands**: `' .. table.concat(item.triggers.cmds, '`, `') .. '`') end
      if #item.triggers.load_before > 0 then
        add('- **Load Before**: `' .. table.concat(item.triggers.load_before, '`, `') .. '`')
      end
      if #item.triggers.dep_of > 0 then
        add('- **Dependency Of**: `' .. table.concat(item.triggers.dep_of, '`, `') .. '`')
      end
      if #item.triggers.after > 0 then add('- **After**: `' .. table.concat(item.triggers.after, '`, `') .. '`') end
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
    '*Actions: `<CR>` jump to spec | `<C-l>` trigger load | `<A-u>` check update | `<C-o>` browse store files | `<C-h>` help | `<C-r>` README*'
  )

  ctx.preview:set_lines(lines)
  ctx.preview:highlight({ ft = 'markdown' })
end

function M.confirm(picker, item)
  picker:close()
  if not item then return end
  if item.spec_file and item.pos then
    vim.cmd.edit(item.spec_file)
    vim.api.nvim_win_set_cursor(0, item.pos)
  elseif item.path then
    Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' })
  end
end

M.actions = {
  browse_store = function(picker, item)
    picker:close()
    if item and item.path then Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' }) end
  end,
  toggle_load = function(picker, item)
    if item and not item.loaded then
      if nixInfo and nixInfo.lze then
        nixInfo.lze.trigger_load(item.name)
      elseif package.loaded['lze'] then
        require('lze').trigger_load(item.name)
      end
      item.loaded = true
      item.status = 'loaded'
      item.text = item.name .. ' loaded ' .. (item.version or '') .. ' ' .. (item.trigger_summary or '')
      Snacks.notify('Loaded ' .. item.name, { title = 'Plugins' })
      picker:find()
    end
  end,
  check_update = function(picker, item)
    if not item or not item.repo or not item.rev then
      Snacks.notify('No repository or revision metadata available for ' .. (item and item.name or 'selected plugin'), {
        title = 'Plugins',
        level = 'warn',
      })
      return
    end

    local name = item.name
    local repo = item.repo
    local rev = item.rev

    update_cache[name] = { status = 'checking' }
    picker:find()
    Snacks.notify('Checking GitHub for ' .. name .. ' (' .. repo .. ')...', { title = 'Plugins' })

    local cmd = {
      'curl',
      '-sL',
      '--max-time',
      '5',
      '-H',
      'Accept: application/vnd.github.v3+json',
      'https://api.github.com/repos/' .. repo .. '/commits/HEAD',
    }

    vim.system(cmd, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code ~= 0 or not obj.stdout or obj.stdout == '' then
          update_cache[name] = { status = 'error', err = 'Network failure' }
          Snacks.notify('Failed to check updates for ' .. name, { title = 'Plugins', level = 'error' })
        else
          local ok, data = pcall(vim.json.decode, obj.stdout)
          if ok and data and data.sha then
            local remote_sha = data.sha:sub(1, 7)
            local local_sha = rev:sub(1, 7)
            if rev == data.sha or data.sha:find(rev, 1, true) or rev:find(remote_sha, 1, true) then
              update_cache[name] = { status = 'up-to-date', remote_sha = remote_sha }
              Snacks.notify(name .. ' is up to date (' .. remote_sha .. ')', { title = 'Plugins', level = 'info' })
            else
              update_cache[name] = { status = 'update-available', remote_sha = remote_sha }
              Snacks.notify(
                'Update available for ' .. name .. '! Pinned: ' .. local_sha .. ', Upstream: ' .. remote_sha,
                {
                  title = 'Plugins',
                  level = 'warn',
                }
              )
            end
          else
            local msg = (ok and data and data.message) or 'Invalid response'
            update_cache[name] = { status = 'error', err = msg }
            Snacks.notify(
              'GitHub API error for ' .. name .. ': ' .. tostring(msg),
              { title = 'Plugins', level = 'error' }
            )
          end
        end
        picker:find()
      end)
    end)
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
}

---@param opts? snacks.picker.Config
function M.setup(opts)
  return vim.tbl_deep_extend('force', {
    title = 'Plugins (lze)',
    finder = function() return M.get_items() end,
    format = M.format,
    preview = M.preview,
    confirm = M.confirm,
    actions = M.actions,
    win = {
      input = {
        keys = {
          ['<c-o>'] = { 'browse_store', desc = 'Browse store files' },
          ['<c-l>'] = { 'toggle_load', desc = 'Trigger load plugin' },
          ['<a-u>'] = { 'check_update', desc = 'Check for updates' },
          ['<c-r>'] = { 'open_readme', desc = 'Open README.md' },
          ['<c-h>'] = { 'open_help', desc = 'Open help page' },
        },
      },
    },
  }, opts or {})
end

function M.open(opts) return Snacks.picker.pick('plugins', opts) end

M.pick = M.open

return setmetatable(M, {
  __call = function(_, opts) return M.open(opts) end,
})
