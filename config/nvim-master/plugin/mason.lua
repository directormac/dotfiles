require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/mason-org/mason.nvim', version = vim.version.range('*') },
    { src = 'https://github.com/zapling/mason-lock.nvim' },
  })

  require('mason').setup({ PATH = 'append' })

  require('mason-lock').setup({
    lockfile_path = vim.env.DOTFILES .. '/config/nvim-super/mason-lock.json',
  })

  -- Kept alphabetical; the trailing comment is the language/tool that needs it.
  local ensure_installed = {
    'bash-language-server', -- bash
    'json-lsp', -- json
    'lua-language-server', -- lua
    'markdownlint', -- markdown
    'shellcheck', -- bash (bashls runs it itself; not a nvim-lint linter)
    'shfmt', -- bash
    'stylua', -- lua
    'taplo', -- toml
  }

  -- Project-local additions from a .nvim.lua (exrc), e.g.:
  --   Config.mason_extra = {
  --     mason = { "mdformat" },
  --     mason_pip = { mdformat = { "mdformat-gfm==1.0.0" } },
  --   }
  -- exrc runs at startup step 7c, before this VimEnter callback, so the table is
  -- always populated by the time it is read here.
  local extra = Config.mason_extra or {}
  ensure_installed = vim.list_extend(ensure_installed, extra.mason or {})

  local mason_registry = require('mason-registry')

  mason_registry:on(
    'package:install:success',
    vim.schedule_wrap(function(pkg) vim.notify(pkg.name .. ' installed', 'info', { title = 'Mason' }) end)
  )

  mason_registry:on(
    'package:install:failed',
    vim.schedule_wrap(
      function(pkg, err)
        vim.notify(('mason install of %s failed: %s'):format(pkg.name, vim.inspect(err)), vim.log.levels.ERROR)
      end
    )
  )

  mason_registry.refresh(function()
    for _, pkg_name in ipairs(ensure_installed) do
      local ok, pkg = pcall(mason_registry.get_package, pkg_name)
      if not ok then
        vim.notify(('mason: unknown package %q'):format(pkg_name), vim.log.levels.WARN)
      elseif not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end)
