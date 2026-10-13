---@type lze.Handler
local M = {
  spec_field = 'rtp',
  set_lazy = false,
}

---Locate the root path of a plugin by name
---@param pname string
---@return string|nil
local function get_plugin_path(pname)
  if _G.nixInfo and nixInfo.get_nix_plugin_path then
    local p = nixInfo.get_nix_plugin_path(pname)
    if p then return p end
  end
  for _, packpath in ipairs(vim.opt.packpath:get()) do
    local opt_match = vim.fn.globpath(packpath, 'pack/*/opt/' .. pname, nil, true, true)
    if opt_match[1] then return opt_match[1] end
    local start_match = vim.fn.globpath(packpath, 'pack/*/start/' .. pname, nil, true, true)
    if start_match[1] then return start_match[1] end
  end
  return nil
end

---Startup hook to discover and source ftdetect files from opt plugins
---so that Neovim can detect custom filetypes without needing full plugin loading upfront.
function M.init()
  local ok, rtp = pcall(require, 'rtp_nvim')
  if not ok then return end

  for _, packpath in ipairs(vim.opt.packpath:get()) do
    local ftdetects = vim.fn.globpath(packpath, 'pack/*/opt/*/ftdetect', nil, true, true)
    for _, ftpath in ipairs(ftdetects) do
      for _, script in ipairs(vim.fn.globpath(ftpath, '**/*.{lua,vim}', nil, true, true)) do
        pcall(vim.cmd.source, script)
      end
    end
  end
end

---Called after a plugin's load hook and packadd, but before its after hook.
---Sources after/plugin and ensures ftdetect scripts are executed.
---@param name string
function M.after(name)
  local ok, rtp = pcall(require, 'rtp_nvim')
  if not ok then return end

  local path = get_plugin_path(name)
  if not path then return end

  -- Source after/plugin if present
  local after_plugin = vim.fs.joinpath(path, 'after', 'plugin')
  if vim.uv.fs_stat(after_plugin) then rtp.source_after_plugin_dir(path) end

  -- Source ftdetect if present
  local ftdetect = vim.fs.joinpath(path, 'ftdetect')
  if vim.uv.fs_stat(ftdetect) then rtp.source_rtp_dir(path) end
end

return M
