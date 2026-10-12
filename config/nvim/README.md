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
    keys = {
      { '<leader>fo', '<cmd>Oil<cr>', desc = 'Oil explorer' },
    },
    after = function()
      require('oil').setup({ ... })
      require('lz.n').trigger_load({ 'oil-git.nvim', 'oil-lsp-diagnostics.nvim' })
    end,
  },
  { 'oil-git.nvim' },
  { 'oil-lsp-diagnostics.nvim' },
}
```

### Spec Fields

| Field | Type | Description |
| --- | --- | --- |
| `[1]` | `string` | Plugin name in packpath (e.g. `'snacks.nvim'`) |
| `event` | `string \| string[]` | Load on event (e.g. `'DeferredUIEnter'`, `'BufReadPre'`) |
| `cmd` | `string \| string[]` | Load on command (e.g. `'GrugFar'`) |
| `ft` | `string \| string[]` | Load on filetype |
| `keys` | `table` | Keymaps that trigger loading |
| `colorscheme` | `string` | Colorscheme name that triggers loading |
| `load_before` | `string \| string[]` | Loads this plugin before the target plugin(s) load (via custom `load_before` handler) |
| `on_require` | `string \| string[]` | Loads this plugin when any of the module prefixes are required (via custom `on_require` handler) |
| `before` | `fun()` | Executed before plugin is loaded |
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

## LSP Configuration

Language servers are enabled in `lua/plugins/lsp.lua` via Neovim's native `vim.lsp.enable(server)`. Neovim automatically creates `FileType` autocommands to attach servers when matching buffers are opened. Server-specific configurations are stored in `lsp/<server>.lua` and merged automatically.
