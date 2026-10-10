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
| `before` | `fun()` | Executed before plugin is loaded |
| `after` | `fun()` | Executed after plugin is loaded (equivalent to `config` in lazy.nvim) |

## LSP Configuration

Language servers are enabled in `lua/plugins/lsp.lua` via Neovim's native `vim.lsp.enable(server)`. Neovim automatically creates `FileType` autocommands to attach servers when matching buffers are opened. Server-specific configurations are stored in `lsp/<server>.lua` and merged automatically.