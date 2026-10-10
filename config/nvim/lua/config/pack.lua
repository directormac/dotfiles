-- `pkgs` handler: install spec-declared plugins with vim.pack (Neovim's builtin).
--
--   { 'tuxedo.nvim', pkgs = { 'IogaMaster/tuxedo.nvim' }, keys = { ... } }
--
-- Every `pkgs` list collected here is installed on VimEnter with
-- `vim.pack.add(..., { confirm = false, load = false })`: the plugin lands on disk
-- and on the runtimepath, but its `plugin/` files are NOT sourced, so lazy loading
-- still works. The spec's own `load` hook packadd's the `pkgs` directories first
-- (that is what sources `plugin/`), and installs on demand if a trigger fires
-- before VimEnter (or VimEnter failed, e.g. offline).
--
-- Conventions:
--   * the `pkgs` list must contain the plugin itself; deps go in the same list
--   * do not also declare the plugin in neovim.nix (two copies on the runtimepath)
--   * no `auto_enable` on a pkgs spec: nix never installed it, so it would disable itself

local M = {}

local all_pkgs = {}
local plugin_pkgs = {}
local packed = {}

-- same name derivation as vim.pack: `spec.name`, else basename of src without `.git`
local function plug_name(p) return (p.name or p.src:gsub('%.git$', '')):match('[^/]+$') end

local function resolve(pkgs)
  return vim.tbl_map(function(p)
    if type(p) == 'string' then return { src = p:find('://', 1, true) and p or ('https://github.com/' .. p) } end
    return p
  end, pkgs or {})
end

-- packadd re-sources plugin/ files on every call, so only do it once per directory
local function packadd_once(dir)
  if packed[dir] then return end
  packed[dir] = true
  vim.cmd.packadd(dir)
end

M.handler = {
  spec_field = 'pkgs',
  -- `pkgs` is about installation, not laziness: triggers decide when it loads
  set_lazy = false,
  modify = function(plugin)
    local pkgs = resolve(plugin.pkgs)
    plugin_pkgs[plugin.name] = pkgs
    vim.list_extend(all_pkgs, pkgs)
    plugin.load = function(name)
      local own = plugin_pkgs[name] or {}
      if #own > 0 then
        -- no-op once vim.pack has seen these this session; installs if the
        -- trigger fires before the VimEnter batch install
        local ok, err = pcall(vim.pack.add, own, { confirm = false, load = false })
        if not ok then
          vim.notify(
            'vim.pack could not install ' .. name .. ':\n' .. tostring(err),
            vim.log.levels.WARN,
            { title = 'pack' }
          )
        end
        for _, p in ipairs(own) do
          packadd_once(plug_name(p))
        end
        if packed[name] then return end -- the spec name was one of the pkgs directories
      end
      packadd_once(name) -- nix packdir plugin, or a silent no-op if truly absent
    end
    return plugin
  end,
}

function M.setup()
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      if #all_pkgs == 0 then return end
      local seen, list, declared = {}, {}, {}
      for _, p in ipairs(all_pkgs) do
        if not seen[p.src] then
          seen[p.src] = true
          list[#list + 1] = p
          declared[plug_name(p)] = true
        end
      end
      local ok, err = pcall(vim.pack.add, list, { confirm = false, load = false })
      if not ok then
        vim.notify('vim.pack install failed:\n' .. tostring(err), vim.log.levels.WARN, { title = 'pack' })
        return -- declared plugins are not active yet, cleanup below would delete them
      end
      -- remove managed (site/pack/core/opt) plugins no spec declares any more;
      -- nix packdir plugins live elsewhere and are never touched
      local orphans = {}
      for _, plug in ipairs(vim.pack.get()) do
        local name = plug.spec and plug.spec.name
        if not plug.active and name and not declared[name] then orphans[#orphans + 1] = name end
      end
      if #orphans > 0 then pcall(vim.pack.del, orphans) end
    end,
  })
end

return M
