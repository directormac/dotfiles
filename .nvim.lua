-- 1. Define the custom LSP configuration for tmux
vim.lsp.config('tmux_ls', {
  cmd = { 'tmux-language-server' },
  filetypes = { 'tmux' },
  root_markers = { '.git', '.tmux.conf', 'tmux.conf' },
})

-- 2. Enable it globally (automatically attaches when filetype matches)
vim.lsp.enable('tmux_ls')

vim.filetype.add({
  pattern = {
    ['.*tmux%.conf'] = 'tmux',
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- Example keymaps for navigation/inspection
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded', silent = true }) end, opts)

    -- Enable built-in completion if supported
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- vim.treesitter.language.add('python', { path = "" })
vim.treesitter.language.register('tmux', { 'conf', 'tmux' })

vim.lsp.enable('copilot')

-- Read more here https://swarsel.github.io/pedantix/configuration.html
-- or type `:h exrc`

require('conform').setup({
  format_on_save = function()
    if not vim.g.auto_format then return end
    return { timeout_ms = 5000, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    nix = { 'treefmt', 'nixfmt', stop_after_first = true },
    lua = { 'treefmt', 'stylua', stop_after_first = true },
    toml = { 'treefmt', 'taplo', stop_after_first = true },
    markdown = { 'treefmt', 'mdformat', stop_after_first = true },
    yaml = { 'treefmt', 'yamlfmt', stop_after_first = true },
    sh = { 'treefmt', 'shfmt', stop_after_first = true },
    bash = { 'treefmt', 'shfmt', stop_after_first = true },
    json = { 'treefmt', 'oxfmt', stop_after_first = true },
    jsonc = { 'treefmt', 'oxfmt', stop_after_first = true },
  },
})

---@type vim.lsp.Config
vim.lsp.config('nil_ls', {
  ---@type lspconfig.settings.nil_ls
  settings = {
    formatting = {
      command = { 'treefmt' },
    },
  },
})

---@type vim.lsp.Config
vim.lsp.config('nixd', {
  ---@type lspconfig.settings.nixd
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }',
      },
      formatting = {
        command = { 'treefmt' },
      },
      options = {
        nixos = {
          expr = '(let flake = builtins.getFlake (toString ./.); pkgs = import flake.inputs.nixpkgs { }; in (pkgs.lib.evalModules { modules = (import "${flake.inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options',
        },
        home_manager = {
          expr = '(let flake = builtins.getFlake (toString ./.); pkgs = import flake.inputs.nixpkgs { }; lib = import "${flake.inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib; in (lib.evalModules { modules = (import "${flake.inputs.home-manager}/modules/modules.nix") { inherit lib pkgs; check = false; }; })).options',
        },
      },
    },
  },
})

vim.lsp.enable({
  'lua_ls',
  'nixd',
  'taplo',
  'nil_ls',
  'bashls',
  'yamlls',
  'marksman',
  'jsonls',
})
