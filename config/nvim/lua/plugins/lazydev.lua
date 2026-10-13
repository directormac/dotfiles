-- lazydev.nvim: loads only the relevant definitions for a lua file,
-- and correlates the globals we create with our own files.
return {
  'lazydev.nvim',
  cmd = { 'LazyDev' },
  ft = 'lua',
  on_require = { 'lazydev' },
  after = function(_)
    local library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
      { path = 'nvim-lspconfig', words = { 'lspconfig.settings' } },
    }

    local lzn_path = nixInfo.get_nix_plugin_path('lz.n')
    if lzn_path and vim.uv.fs_stat(lzn_path .. '/lua') then
      table.insert(library, {
        words = { 'lz%.n', 'nixInfo%.lzn' },
        path = lzn_path .. '/lua',
      })
    end

    if _G.nixInfo and nixInfo.plugins then
      local function add_plugins(tbl)
        for name, path in pairs(tbl or {}) do
          if name ~= 'lz.n' and vim.uv.fs_stat(path .. '/lua') then
            local clean_name = name:gsub('%.nvim$', ''):gsub('^nvim%-', '')
            table.insert(library, {
              path = path .. '/lua',
              words = { name, clean_name },
              mods = { name, clean_name },
            })
          end
        end
      end
      add_plugins(nixInfo.plugins.start)
      add_plugins(nixInfo.plugins.lazy)
    end

    require('lazydev').setup({
      library = library,
    })
  end,
}
