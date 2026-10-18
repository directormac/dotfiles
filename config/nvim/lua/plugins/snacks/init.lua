local spec = {
  'snacks.nvim',
  auto_enable = true,
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    ---@class snacks.profiler.Config
    profiler = {
      enabled = true,
      filter_mod = {
        ['^vim%.lsp'] = false,
        ['^gitsigns'] = false,
        ['^conform'] = false,
      },
    },
  },
  keys = {
    {
      '<leader>ps',
      function() Snacks.profiler.scratch() end,
      desc = 'Profiler Scratch Buffer',
    },
  },
}

-- Dynamically find and merge all sibling files in lua/plugins/snacks/*.lua
local runtime_dirs = vim.api.nvim_get_runtime_file('lua/plugins/snacks', true)
for _, snacks_dir in ipairs(runtime_dirs) do
  for name, ftype in vim.fs.dir(snacks_dir) do
    if (ftype == 'file' or ftype == 'link') and name:sub(-4) == '.lua' and name ~= 'init.lua' then
      local modname = 'plugins.snacks.' .. name:sub(1, -5)
      local ok, mod = pcall(require, modname)
      if ok and type(mod) == 'table' then
        Utils.merge_specs(spec, mod)
      elseif not ok then
        vim.notify('Error loading ' .. modname .. ': ' .. tostring(mod), vim.log.levels.WARN)
      end
    end
  end
end

return spec
