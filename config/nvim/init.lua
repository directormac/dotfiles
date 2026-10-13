-- Ordering only. Layout:
--   lua/          options, keymaps, autocmds, diagnostics, utils, handlers
--   lua/plugins/  one file per plugin, returning pure lze specs (return { ... })
--   lsp/          server settings, merged by vim.lsp.config (see :h lsp-config-merge)
--   ftplugin/     filetype settings      after/  overrides, applied last
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

_G._startup_time = vim.uv.hrtime()
vim.loader.enable() -- <- bytecode caching

-- [[ Startup Profiling ]]
-- Profile Neovim startup if PROFILER=1 or PROF=1 is set in the environment
if vim.env.PROFILER == '1' or vim.env.PROF == '1' then
  -- Nix wrapper installs snacks.nvim as a startup plugin (lazy = false in
  -- neovim.nix), so it's already on the runtimepath here. No rtp append needed.
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter',
      -- event = 'DeferredUIEnter', -- stop profiling at this event
    },
  })
  -- local ok, profiler = pcall(require, "snacks.profiler")
  -- if ok and profiler then
  -- 	profiler.startup({
  -- 		startup = {
  -- 			event = "VimEnter",
  -- 		},
  -- 	})
  -- end
end

do
  -- Set up a global in a way that also handles non-nix compat
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function(_, default) return default end,
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
    -- If you always use the fetcher function to fetch nix values,
    -- rather than indexing into the tables directly,
    -- it will use the value you specified as the default
    -- TODO: for non-nix compat, vim.pack.add in another file and require here.
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, 'plugins', 'lazy', name) or nixInfo(nil, 'plugins', 'start', name)
  end

  ---Check if a category or condition is enabled
  ---Supports:
  ---  string: "lua"
  ---  list of strings (all must match): { "lua", "dev" }
  ---  table with any: { any = { "lua", "nix" } }
  ---  table with all: { all = { "lua", "stylua" } }
  ---@param cat string|table
  ---@return boolean
  function nixInfo.has_cat(cat)
    if not nixInfo.isNix then return true end
    if type(cat) == 'string' then
      return nixInfo(false, 'settings', 'cats', cat) == true
    elseif type(cat) == 'table' then
      if cat.any and type(cat.any) == 'table' then
        for _, c in ipairs(cat.any) do
          if nixInfo.has_cat(c) then return true end
        end
        return false
      elseif cat.all and type(cat.all) == 'table' then
        for _, c in ipairs(cat.all) do
          if not nixInfo.has_cat(c) then return false end
        end
        return true
      else
        for _, c in ipairs(cat) do
          if not nixInfo.has_cat(c) then return false end
        end
        return true
      end
    end
    return false
  end
end

_G.Utils = require('utils')

nixInfo.lze.register_handlers({
  require('handlers.opts'),
  require('handlers.rtp'),
  require('handlers.load_before'),
  require('handlers.on_require'),
  {
    -- adds an `auto_enable` field to lze specs
    -- if true, will disable it if not installed by nix.
    -- if string, will disable if that name was not installed by nix.
    -- if a table of strings, it will disable if any were not.
    spec_field = 'auto_enable',
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.auto_enable) == 'table' then
          for _, name in pairs(plugin.auto_enable) do
            if not nixInfo.get_nix_plugin_path(name) then
              plugin.enabled = false
              break
            end
          end
        elseif type(plugin.auto_enable) == 'string' then
          if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then plugin.enabled = false end
        elseif type(plugin.auto_enable) == 'boolean' and plugin.auto_enable then
          if not nixInfo.get_nix_plugin_path(plugin.name) then plugin.enabled = false end
        end
      end
      return plugin
    end,
  },
  {
    -- Category check handler
    -- give for_cat = "name" or for_cat = { "cat1", "cat2" } or for_cat = { any = { ... } }
    -- to disable if the category is not enabled in Nix.
    spec_field = 'for_cat',
    set_lazy = false,
    modify = function(plugin)
      -- Do not re-enable if explicitly disabled
      if plugin.enabled == false then return plugin end
      if plugin.for_cat ~= nil then
        if not nixInfo.has_cat(plugin.for_cat) then plugin.enabled = false end
      end
      return plugin
    end,
  },
  -- From lzextras. This one makes it so that
  -- you can set up lsps within lze specs,
  -- and trigger lspconfig setup hooks only on the correct filetypes
  -- It is (unfortunately) important that it be registered after the above 2,
  -- as it also relies on the modify hook, and the value of enabled at that point
  nixInfo.lze.lsp,
  nixInfo.lze.merge,
  -- nixInfo.lze.keymap,

  -- nixInfo.lze.make_load_with_afters,
  -- nixInfo.lze.key2spec,
})

-- [[ Core Configurations ]]
require('options')
require('keymaps')
require('autocmds')
require('diagnostics')

-- Load modular plugin specifications from lua/plugins/*.lua
nixInfo.lze.load(nixInfo.lze.mod_dir_to_spec('plugins'))

-- Apply colorscheme (lazily loaded via lze colorscheme handler)
vim.cmd.colorscheme(nixInfo('catppuccin', 'settings', 'colorscheme'))
