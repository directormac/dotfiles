-- vim.pack keymaps  (<leader>p = pack)
vim.keymap.set('n', '<leader>pp', '<cmd>Pack<cr>', { desc = 'Pack UI' })
vim.keymap.set('n', '<leader>pu', '<cmd>lua vim.pack.update(nil, {force = true })<cr>', { desc = 'Pack Update All' })
vim.keymap.set('n', '<leader>pd', function()
  vim.ui.input({ prompt = 'Plugin name to delete: ' }, function(input)
    if input and input ~= '' then pcall(vim.pack.del, { input }) end
  end)
end, { desc = 'Pack Delete' })

-- ui
local api = vim.api
local ns = api.nvim_create_namespace('pack_ui')

local HL = {
  PackUiHeader = 'Title',
  PackUiButton = 'Function',
  PackUiLoaded = 'String',
  PackUiUnloaded = 'Comment',
  PackUiVersion = 'Number',
  PackUiSection = 'Label',
  PackUiSep = 'FloatBorder',
  PackUiDetail = 'Comment',
}

local state = { bufnr = nil, winid = nil, expanded = {} }

local function render()
  if not (state.bufnr and api.nvim_buf_is_valid(state.bufnr)) then return end

  local plugins = vim.pack.get(nil, { info = false })
  local loaded, unloaded = {}, {}
  for _, p in ipairs(plugins) do
    table.insert(p.active and loaded or unloaded, p)
  end
  local cmp = function(a, b) return a.spec.name < b.spec.name end
  table.sort(loaded, cmp)
  table.sort(unloaded, cmp)

  local lines, marks = {}, {}
  state.lmap = {}

  local function put(text, hl_group)
    lines[#lines + 1] = text
    if hl_group then marks[#marks + 1] = { #lines - 1, 0, #text, hl_group } end
  end
  local function hl(lnum, s, e, group) marks[#marks + 1] = { lnum, s, e, group } end

  local w = state.winid and api.nvim_win_get_width(state.winid) or 80

  put((' vim.pack  %d plugins  (%d loaded, %d not loaded)'):format(#plugins, #loaded, #unloaded), 'PackUiHeader')
  put(' ' .. ('─'):rep(w - 1), 'PackUiSep')

  local bar = '  [U] Update All   [u] Update   [D] Delete'
  put(bar)
  for s, e in bar:gmatch('()%[.-%]()') do
    hl(#lines - 1, s - 1, e - 1, 'PackUiButton')
  end

  local max_w = vim.iter(plugins):fold(0, function(acc, p) return math.max(acc, #p.spec.name) end)

  local function render_plugin(p, icon, grp)
    local name = p.spec.name
    local ver = p.spec.version and tostring(p.spec.version) or (p.rev and p.rev:sub(1, 7) or '')
    local pad = (' '):rep(max_w - #name + 2)
    put(('  %s %s%s%s'):format(icon, name, pad, ver))

    local lnum = #lines - 1
    state.lmap[lnum + 1] = name
    hl(lnum, 2, 2 + #icon, grp)
    hl(lnum, 3 + #icon, 3 + #icon + #name, grp)
    if #ver > 0 then
      local vs = 3 + #icon + #name + #pad
      hl(lnum, vs, vs + #ver, 'PackUiVersion')
    end

    if state.expanded[name] then
      put(('    path : %s'):format(p.path or '?'), 'PackUiDetail')
      put(('    src  : %s'):format(p.spec.src or '?'), 'PackUiDetail')
      if p.rev then put(('    rev  : %s'):format(p.rev), 'PackUiDetail') end
    end
  end

  put('')
  put((' Loaded (%d)'):format(#loaded), 'PackUiSection')
  for _, p in ipairs(loaded) do
    render_plugin(p, '●', 'PackUiLoaded')
  end

  if #unloaded > 0 then
    put('')
    put((' Not Loaded (%d)'):format(#unloaded), 'PackUiSection')
    for _, p in ipairs(unloaded) do
      render_plugin(p, '○', 'PackUiUnloaded')
    end
  end

  vim.bo[state.bufnr].modifiable = true
  api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  vim.bo[state.bufnr].modifiable = false
  api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
  for _, m in ipairs(marks) do
    api.nvim_buf_set_extmark(state.bufnr, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
end

local function cursor_plugin()
  if not (state.winid and api.nvim_win_is_valid(state.winid)) then return end
  return state.lmap[api.nvim_win_get_cursor(state.winid)[1]]
end

local function close()
  if state.winid and api.nvim_win_is_valid(state.winid) then api.nvim_win_close(state.winid, true) end
  state.winid, state.bufnr, state.expanded = nil, nil, {}
end

local function open()
  if state.winid and api.nvim_win_is_valid(state.winid) then
    api.nvim_set_current_win(state.winid)
    return
  end

  for g, link in pairs(HL) do
    api.nvim_set_hl(0, g, { link = link, default = true })
  end

  state.bufnr = api.nvim_create_buf(false, true)
  vim.bo[state.bufnr].buftype = 'nofile'
  vim.bo[state.bufnr].bufhidden = 'wipe'
  vim.bo[state.bufnr].filetype = 'pack-ui'

  local cols, rows = vim.o.columns, vim.o.lines
  local W = math.min(cols - 4, math.max(math.floor(cols * 0.8), 60))
  local H = math.min(rows - 4, math.max(math.floor(rows * 0.8), 20))
  state.winid = api.nvim_open_win(state.bufnr, true, {
    relative = 'editor',
    width = W,
    height = H,
    row = math.floor((rows - H) / 2),
    col = math.floor((cols - W) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' vim.pack ',
    title_pos = 'center',
  })
  vim.wo[state.winid].cursorline = true
  vim.wo[state.winid].wrap = false

  render()

  local o = { buffer = state.bufnr, silent = true, nowait = true }

  vim.keymap.set('n', 'q', close, o)
  vim.keymap.set('n', '<Esc>', close, o)
  vim.keymap.set('n', '<CR>', function()
    local name = cursor_plugin()
    if not name then return end
    state.expanded[name] = not state.expanded[name]
    render()
    for lnum, n in pairs(state.lmap) do
      if n == name then
        api.nvim_win_set_cursor(state.winid, { lnum, 0 })
        break
      end
    end
  end, o)

  vim.keymap.set('n', 'U', function()
    close()
    vim.pack.update(nil, { force = true })
  end, o)

  vim.keymap.set('n', 'u', function()
    local name = cursor_plugin()
    if not name then return end
    close()
    vim.pack.update({ name })
  end, o)

  vim.keymap.set('n', 'D', function()
    local name = cursor_plugin()
    if not name then return end
    close()
    local ok, err = pcall(vim.pack.del, { name })
    vim.notify(
      ok and ('vim.pack: deleted %s'):format(name) or 'vim.pack: ' .. tostring(err),
      ok and vim.log.levels.INFO or vim.log.levels.ERROR
    )
  end, o)

  api.nvim_create_autocmd('WinClosed', {
    buffer = state.bufnr,
    once = true,
    callback = function(ev)
      if vim._tointeger(ev.match) == state.winid then
        state.winid, state.bufnr, state.expanded = nil, nil, {}
      end
    end,
  })
end

vim.api.nvim_create_user_command('Pack', open, { desc = 'Open vim.pack plugin manager UI' })
