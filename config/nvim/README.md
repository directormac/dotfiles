# Neovim configuration

This directory is a plain Neovim runtime directory (a `runtimepath` entry), managed via
[`nixos/modules/apps/neovim.nix`](../../nixos/modules/apps/neovim.nix) through
`settings.config_directory` with `nix-wrapper-modules`.

## Architecture Overview

This setup uses [`lz.n`](https://github.com/lumen-oss/lz.n) for lazy-loading and Neovim 0.11+'s native `vim.lsp.enable` engine for LSP management.

| Directory | Sourced | Use it for |
| --- | --- | --- |
| `init.lua` | `dofile`'d by wrapper (`INIT_MAIN`) | ordering, loading config and `require('lz.n').load('plugins')` |
| `lua/config/**` | required by `init.lua` | `bootstrap.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`, `diagnostics.lua` |
| `lua/plugins/**` | loaded by `lz.n.load('plugins')` | pure `return { ... }` plugin specs |
| `lsp/<server>.lua` | merged into `vim.lsp.config('<server>')` when client starts | LSP server settings |
| `ftplugin/<ft>.lua` | on `FileType=<ft>` | per-filetype tweaks |

## Plugin Specs (`lz.n`)

Every plugin spec lives in `lua/plugins/<name>.lua` and simply returns a table:

```lua
-- lua/plugins/oil.lua
return {
  {
    'oil.nvim',
    cmd = { 'Oil' },
    keys = {
      { '<leader>fo', '<cmd>Oil<cr>', desc = 'Oil explorer' },
    },
    after = function()
      require('oil').setup({ ... })
    end,
  },
  { 'oil-git.nvim', load_before = { 'oil.nvim' } },
  { 'oil-lsp-diagnostics.nvim', load_before = { 'oil.nvim' } },
}
```

### Spec Fields

| Field | Type | Description |
| --- | --- | --- |
| `[1]` | `string` | Plugin name in packpath (e.g. `'snacks.nvim'`) |
| `event` | `string \| string[]` | Load on event (e.g. `'DeferredUIEnter'`, `'BufReadPost'`, `'CmdlineEnter'`) |
| `cmd` | `string \| string[]` | Load on command (e.g. `'Oil'`, `'GrugFar'`) |
| `ft` | `string \| string[]` | Load on filetype (e.g. `'markdown'`, `'lua'`) |
| `keys` | `table \| fun()` | Keymaps that trigger loading |
| `colorscheme` | `string` | Colorscheme name that triggers loading |
| `load_before` | `string \| string[]` | Loads this plugin before the target plugin(s) load (via custom `load_before` handler) |
| `on_require` | `string \| string[]` | Loads this plugin when any of the module prefixes are required (via custom `on_require` handler) |
| `before` | `fun()` | Executed before plugin is loaded (useful for setting global variables) |
| `after` | `fun()` | Executed after plugin is loaded (equivalent to `config` in lazy.nvim) |

## Handlers & Auto-Requiring Architecture

This configuration uses a layered strategy for dependency loading and on-demand requires:

1. **`load_before` (Inter-plugin Dependency Ordering)**:
   - Defined in `lua/config/load_before.lua`.
   - Used when Plugin A must be loaded and initialized (including its `:setup()` and hooks) before Plugin B starts loading.
   - Example: `harpoon2` (`load_before = { 'harpoon-lualine' }`) &rarr; `harpoon-lualine` (`load_before = { 'lualine.nvim' }`) &rarr; `lualine.nvim`.

2. **`on_require` (Explicit Fast-Path Module Loading)**:
   - Defined in `lua/config/on_require.lua`.
   - Used for common shared dependencies in `lua/plugins/common.lua` (`plenary`, `nui`, `nio`).
   - Resolves modules in-memory with zero disk/filesystem scanning overhead.

3. **`lzn-auto-require` (Filesystem Fallback Scanner)**:
   - Sourced via `require('lzn-auto-require').enable()` in `init.lua`.
   - Scans `packpath` for `opt/<plugin>/lua/<module>.lua` when an undeclared module is required.

### Conflict Analysis & Layering
`on_require` and `lzn-auto-require` complement each other cleanly without conflicts:
- When `require('mod')` is invoked, `on_require`'s wrapper evaluates first against in-memory registered specs. If matched (e.g. `plenary`, `nui`), the plugin loads instantly in microseconds without disk I/O.
- If the module was not declared in any `on_require` spec, the call falls through to `lzn-auto-require`, which scans `packpath` as a dynamic fallback safety net.
- If neither finds the module, the standard Lua "module not found" error is raised with clean stack traces.

## Complex Real-World Handler Examples

### 1. Direct Module `require()` via `on_require`
Any plugin declared with `on_require` can be required directly from an `after` hook, keymap, command, or autocmd. No manual `trigger_load` is needed:

```lua
-- In lua/plugins/common.lua:
{ 'plenary.nvim', on_require = { 'plenary' } },

-- In lua/plugins/codecompanion.lua (or any other plugin):
after = function()
  -- Plenary is loaded on-the-fly the moment codecompanion requires it:
  require('codecompanion').setup({})
end,
```

### 2. Multi-Level `load_before` Dependency Chains
When plugins must be in `runtimepath` or initialized before another plugin loads:

```lua
-- Snippets & Completion Chain:
-- friendly-snippets -> luasnip -> blink.cmp
{
  'friendly-snippets',
  load_before = { 'luasnip' },
},
{
  'luasnip',
  load_before = { 'blink.cmp' },
  on_require = { 'luasnip' },
},
{
  'blink.cmp',
  event = { 'BufReadPost', 'BufNewFile', 'CmdlineEnter' },
},
```

### 3. Cross-Plugin Coordination via `User DeferredPlugin`
`lz.n` triggers a `User` autocommand with `pattern = 'DeferredPlugin'` and `ev.data = '<plugin-name>'` whenever a plugin is loaded. Use this to defer cross-plugin registrations until the target plugin is ready:

```lua
{
  'mini.align',
  lazy = false,
  after = function()
    require('mini.align').setup()
    -- Register keymaps in which-key after which-key finishes loading
    vim.api.nvim_create_autocmd('User', {
      pattern = 'DeferredPlugin',
      callback = function(ev)
        if ev.data == 'which-key.nvim' then
          require('which-key').add({
            { 'ga', desc = 'Align text', mode = { 'n', 'x' } },
            { 'gA', desc = 'Align text (preview)', mode = { 'n', 'x' } },
          })
          return true -- delete autocmd
        end
      end,
    })
  end,
}
```

### 4. Global Configuration via `before` vs `after`
Plugins that inspect global `vim.g` variables upon being sourced should configure them in `before`. Plugins requiring function initialization go in `after`:

```lua
{
  'vim-startuptime',
  cmd = { 'StartupTime' },
  before = function(_)
    -- Configure globals BEFORE vim-startuptime scripts are sourced
    vim.g.startuptime_event_width = 0
    vim.g.startuptime_tries = 10
  end,
}
```

### 5. Modular Option Aggregation with `Util.merge`
For modular plugin suites like `snacks.nvim`, submodules export partial option tables (`mod.opts`). `Util.merge` recursively deep-merges dictionaries while appending and deduplicating lists:

```lua
-- lua/plugins/snacks/init.lua
local Util = require('config.util')

local merged_opts = {}
for _, mod in ipairs(modules) do
  if mod.opts then merged_opts = Util.merge(merged_opts, mod.opts) end
end

require('snacks').setup(merged_opts)
```

## LSP Configuration

Language servers are enabled in `lua/plugins/lsp.lua` via Neovim's native `vim.lsp.enable(server)`. Neovim automatically creates `FileType` autocommands to attach servers when matching buffers are opened. Server-specific configurations are stored in `lsp/<server>.lua` and merged automatically.
