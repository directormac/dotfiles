local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local parse = ls.parser.parse_snippet

--- Condition that checks whether the active buffer is within the Neovim config directory.
--- When true, Neovim/lze plugin specification snippets activate.
--- When false (e.g. in external projects or scripts), these snippets remain inactive and hidden.
local function in_nvim_config()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == 'snacks_picker_input' then
    if package.loaded['snacks'] and Snacks.picker and Snacks.picker.current and Snacks.picker.current.input then
      local cbuf = Snacks.picker.current.input.filter.current_buf
      if cbuf and vim.api.nvim_buf_is_valid(cbuf) then buf = cbuf end
    else
      local alt = vim.fn.bufnr('#')
      if alt > 0 and vim.api.nvim_buf_is_valid(alt) then buf = alt end
    end
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name ~= '' then
    local path = vim.fs.normalize(name)
    local std_config = vim.fs.normalize(vim.fn.stdpath('config'))
    if path:find(std_config, 1, true) then return true end
    if path:find('/config/nvim', 1, true) then return true end
    if path:find('/%.dotfiles/config/nvim', 1, false) then return true end
    if vim.env.NVIM_DEV_CONFIG and path:find(vim.fs.normalize(vim.env.NVIM_DEV_CONFIG), 1, true) then return true end

    local root = vim.fs.root(path, { 'init.lua' })
    if root and (vim.uv.fs_stat(root .. '/lua/plugins') or vim.uv.fs_stat(root .. '/lua')) then return true end
    return false
  end

  -- Unnamed buffer: check cwd
  local cwd = vim.fs.normalize(vim.uv.cwd() or '')
  local std_config = vim.fs.normalize(vim.fn.stdpath('config'))
  if cwd:find(std_config, 1, true) then return true end
  if cwd:find('/config/nvim', 1, true) then return true end
  if vim.uv.fs_stat(cwd .. '/config/nvim/init.lua') or vim.uv.fs_stat(cwd .. '/init.lua') then return true end

  return false
end

local function cfg_snippet(trig, name, dscr, body)
  return parse({
    trig = trig,
    name = name,
    dscr = dscr,
    condition = in_nvim_config,
    show_condition = in_nvim_config,
  }, body)
end

return {
  -- =========================================================================
  -- 1. Plugin Specifications (lze / lzextras)
  -- =========================================================================
  cfg_snippet(
    'lze',
    'lze Plugin Spec (Basic)',
    'Standard lze plugin spec using automatic opts handler',
    [[return {
  '${1:author/plugin.nvim}',
  event = '${2:DeferredUIEnter}',
  opts = {
    $0
  },
}]]
  ),

  cfg_snippet(
    'plugin',
    'lze Plugin Spec (Basic alias)',
    'Standard lze plugin spec using automatic opts handler',
    [[return {
  '${1:author/plugin.nvim}',
  event = '${2:DeferredUIEnter}',
  opts = {
    $0
  },
}]]
  ),

  cfg_snippet(
    'lzekeys',
    'lze Plugin Spec with Keys',
    'Plugin spec with lazy keybinding and function action',
    [[return {
  '${1:author/plugin.nvim}',
  keys = {
    {
      '${2:<leader>x}',
      function()
        $0
      end,
      desc = '${3:Description}',
    },
  },
  opts = {},
}]]
  ),

  cfg_snippet(
    'lzkeys',
    'lze Plugin Spec with Keys (alias)',
    'Plugin spec with lazy keybinding and function action',
    [[return {
  '${1:author/plugin.nvim}',
  keys = {
    {
      '${2:<leader>x}',
      function()
        $0
      end,
      desc = '${3:Description}',
    },
  },
  opts = {},
}]]
  ),

  cfg_snippet(
    'lzecmd',
    'lze Plugin Spec with Command',
    'Plugin spec lazily loaded on user command',
    [[return {
  '${1:author/plugin.nvim}',
  cmd = { '${2:Command}' },
  opts = {
    $0
  },
}]]
  ),

  cfg_snippet(
    'lzcmd',
    'lze Plugin Spec with Command (alias)',
    'Plugin spec lazily loaded on user command',
    [[return {
  '${1:author/plugin.nvim}',
  cmd = { '${2:Command}' },
  opts = {
    $0
  },
}]]
  ),

  cfg_snippet(
    'lzeit',
    'lze Multi-Plugin Spec with Dependency',
    'Multi-spec table with dependency ordering via load_before',
    [[return {
  {
    '${1:dependency.nvim}',
    load_before = { '${2:main.nvim}' },
  },
  {
    '$2',
    event = '${3:DeferredUIEnter}',
    opts = {
      $0
    },
  },
}]]
  ),

  cfg_snippet(
    'lzdep',
    'lze Multi-Plugin Spec with Dependency (alias)',
    'Multi-spec table with dependency ordering via load_before',
    [[return {
  {
    '${1:dependency.nvim}',
    load_before = { '${2:main.nvim}' },
  },
  {
    '$2',
    event = '${3:DeferredUIEnter}',
    opts = {
      $0
    },
  },
}]]
  ),

  cfg_snippet(
    'lzefull',
    'lze Full Plugin Spec',
    'Comprehensive plugin spec demonstrating category, triggers, keys, and opts',
    [[return {
  '${1:author/plugin.nvim}',
  for_cat = '${2:lua}',
  event = '${3:DeferredUIEnter}',
  cmd = { '${4:Command}' },
  keys = {
    {
      '${5:<leader>x}',
      function()
        $6
      end,
      desc = '${7:Description}',
    },
  },
  opts = {
    $0
  },
}]]
  ),

  -- =========================================================================
  -- 2. Interactive Keymap Entries (for inside keys = { ... })
  -- =========================================================================
  cfg_snippet(
    'fnkey',
    'Keys: Function Action Key',
    'Lazy keymap entry with an interactive Lua function action',
    [[{
  '${1:<leader>x}',
  function()
    $0
  end,
  desc = '${2:Description}',
},]]
  ),

  cfg_snippet(
    'lkey',
    'Keys: Function Action Key (alias)',
    'Lazy keymap entry with an interactive Lua function action',
    [[{
  '${1:<leader>x}',
  function()
    $0
  end,
  desc = '${2:Description}',
},]]
  ),

  cfg_snippet(
    'fnkeym',
    'Keys: Function Action Key with Mode',
    'Lazy keymap entry with Lua function action and explicit modes',
    [[{
  '${1:<leader>x}',
  function()
    $0
  end,
  mode = { '${2:n}' },
  desc = '${3:Description}',
},]]
  ),

  cfg_snippet(
    'cmdkey',
    'Keys: Command Key',
    'Lazy keymap entry running a Vim command',
    [[{ '${1:<leader>x}', '<cmd>${2:Command}<cr>', desc = '${3:Description}' },]]
  ),

  cfg_snippet(
    'ckey',
    'Keys: Command Key (alias)',
    'Lazy keymap entry running a Vim command',
    [[{ '${1:<leader>x}', '<cmd>${2:Command}<cr>', desc = '${3:Description}' },]]
  ),

  cfg_snippet(
    'exprkey',
    'Keys: Expression Function Key',
    'Lazy keymap entry evaluating an expression function',
    [[{
  '${1:<leader>x}',
  function()
    return ${2:expression}
  end,
  expr = true,
  desc = '${3:Description}',
},]]
  ),

  -- Interactive choice node keymap: switch between function action or command string
  s(
    {
      trig = 'keychoice',
      name = 'Keys: Interactive Key Choice',
      dscr = 'Choice node between Lua function action or Vim command keymap',
      condition = in_nvim_config,
      show_condition = in_nvim_config,
    },
    c(1, {
      sn(nil, {
        t({ '{', "  '" }),
        i(1, '<leader>x'),
        t({ "',", '  function()', '    ' }),
        i(2),
        t({ '', '  end,', "  desc = '" }),
        i(3, 'Description'),
        t({ "',", '},' }),
      }),
      sn(nil, {
        t("{ '"),
        i(1, '<leader>x'),
        t("', '<cmd>"),
        i(2, 'Command'),
        t("<cr>', desc = '"),
        i(3, 'Description'),
        t("' },"),
      }),
    })
  ),

  -- =========================================================================
  -- 3. Spec Handlers & Properties (for inserting into existing specs)
  -- =========================================================================
  cfg_snippet(
    'hkeys',
    'Handler: keys block',
    'Keys specification table with function keymap',
    [[keys = {
  {
    '${1:<leader>x}',
    function()
      $0
    end,
    desc = '${2:Description}',
  },
},]]
  ),

  cfg_snippet(
    'hopts',
    'Handler: opts block',
    'Opts table passed automatically to plugin.setup()',
    [[opts = {
  $0
},]]
  ),

  cfg_snippet(
    'hforcat',
    'Handler: for_cat (Nix category)',
    'Enable plugin only when the specified category is active in Nix',
    [[for_cat = '${1:lua}',]]
  ),

  cfg_snippet(
    'hloadbefore',
    'Handler: load_before dependency',
    'Ensure this plugin loads before the target plugin',
    [[load_before = { '${1:plugin-name}' },]]
  ),

  cfg_snippet(
    'honrequire',
    'Handler: on_require module intercept',
    'Intercept module require calls to trigger fast plugin loading',
    [[on_require = { '${1:module-name}' },]]
  ),

  cfg_snippet(
    'hafter',
    'Handler: after hook',
    'Function executed immediately after plugin is loaded and setup',
    [[after = function()
  $0
end,]]
  ),

  cfg_snippet(
    'hbefore',
    'Handler: before hook',
    'Function executed immediately before plugin setup',
    [[before = function()
  $0
end,]]
  ),

  cfg_snippet(
    'hevent',
    'Handler: event trigger',
    'Neovim event trigger string (DeferredUIEnter, VeryLazy, etc.)',
    [[event = '${1:DeferredUIEnter}',]]
  ),

  cfg_snippet('hcmd', 'Handler: cmd trigger', 'Commands that trigger lazy loading', [[cmd = { '${1:Command}' },]]),

  cfg_snippet('hft', 'Handler: ft trigger', 'Filetypes that trigger lazy loading', [[ft = { '${1:filetype}' },]]),

  cfg_snippet(
    'hauto',
    'Handler: auto_enable check',
    'Automatically enable/disable based on Nix installation',
    [[auto_enable = ${1:true},]]
  ),

  -- =========================================================================
  -- 4. Snacks.nvim Integrations
  -- =========================================================================
  cfg_snippet(
    'snackspicker',
    'Snacks: Custom Picker Source',
    'Boilerplate for a custom Snacks picker source with setup and open',
    [[local M = {}

---@param opts? snacks.picker.Config
function M.setup(opts)
  return vim.tbl_deep_extend('force', {
    title = '${1:Title}',
    finder = function(opts, ctx)
      $0
      return {}
    end,
    format = '${2:file}',
    confirm = function(picker, item)
      picker:close()
    end,
  }, opts or {})
end

function M.open(opts) return Snacks.picker.pick('${3:source_name}', opts) end
M.pick = M.open

return setmetatable(M, {
  __call = function(_, opts) return M.open(opts) end,
})]]
  ),

  cfg_snippet(
    'snackstoggle',
    'Snacks: Runtime Toggle',
    'Define and map an interactive Snacks toggle',
    [[Snacks.toggle({
  name = '${1:Toggle Name}',
  get = function()
    return ${2:condition}
  end,
  set = function(state)
    $0
  end,
}):map('${3:<leader>t}')]]
  ),

  cfg_snippet(
    'snacksnotify',
    'Snacks: Notification',
    'Trigger a styled Snacks notification',
    [[Snacks.notify('${1:Message}', { title = '${2:Title}' })]]
  ),
}
