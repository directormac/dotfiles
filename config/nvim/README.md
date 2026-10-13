# Neovim configuration

This directory is a plain Neovim runtime directory (a `runtimepath` entry), managed via
[`nixos/modules/apps/neovim.nix`](../../nixos/modules/apps/neovim.nix) through
`settings.config_directory` with `nix-wrapper-modules`.

## Architecture Overview

This setup uses [`lz.n`](https://github.com/lumen-oss/lz.n) with an enhanced preprocessor engine (`config/specs.lua`) for modular lazy-loading and Neovim 0.11+'s native `vim.lsp.enable` engine for LSP management.

| Directory | Sourced | Use it for |
| --- | --- | --- |
| `init.lua` | `dofile`'d by wrapper (`INIT_MAIN`) | ordering, loading config and `require('lz.n').load('plugins')` |
| `lua/config/**` | required by `init.lua` | `bootstrap.lua`, `specs.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`, `diagnostics.lua` |
| `lua/plugins/**` | loaded by `lz.n.load('plugins')` | pure `return { ... }` plugin specs (discovered recursively) |
| `lsp/<server>.lua` | merged into `vim.lsp.config('<server>')` when client starts | LSP server settings |
| `ftplugin/<ft>.lua` | on `FileType=<ft>` | per-filetype tweaks |

---

## Plugin Specs (`lz.n`) & Modular Structure

Every plugin spec in `lua/plugins/` returns a declarative table or a list of tables.

### 1. Recursive Auto-Discovery
Any `.lua` file placed anywhere inside `lua/plugins/**` is discovered automatically without manual `require()` lists. You can organize files into arbitrary subdirectories:
- `lua/plugins/<plugin>.lua`
- `lua/plugins/ui/<plugin>.lua`
- `lua/plugins/coding/<plugin>.lua`
- `lua/plugins/git/<plugin>.lua`

**Package Boundaries**:
- If a directory under `lua/plugins/` contains an `init.lua` (such as `lua/plugins/snacks/`), it is treated as a self-contained package. The engine imports `plugins.<dir>` as a unit, letting `init.lua` orchestrate its own submodules.
- If a directory does **not** contain `init.lua`, the engine recursively imports every `.lua` file inside it.

### 2. Auto-Default `.setup(opts)`
When a plugin spec defines `opts` and omits `after`, the engine automatically identifies the Lua module name (e.g. `'gitsigns.nvim'` &rarr; `'gitsigns'`) and invokes `require(mod).setup(plugin.opts or {})`.

```lua
-- lua/plugins/todo-comments.lua
return {
  'todo-comments.nvim',
  event = 'DeferredUIEnter',
  opts = {}, -- Automatically calls require('todo-comments').setup({})
}
```

If custom logic (like extra autocmds or Snack toggles) is needed, declare an explicit `after(plugin)` hook, which receives `plugin.opts`:

```lua
-- lua/plugins/gitsigns.lua
return {
  'gitsigns.nvim',
  event = 'DeferredUIEnter',
  opts = {
    signs = { add = { text = '▎' } },
  },
  after = function(plugin)
    require('gitsigns').setup(plugin.opts or {})
    Snacks.toggle({ ... }):map('<leader>uG')
  end,
}
```

### Spec Fields

| Field | Type | Description |
| --- | --- | --- |
| `[1]` | `string` | Plugin name (e.g. `'snacks.nvim'`, `'folke/flash.nvim'`) |
| `event` | `string \| string[]` | Load on event (e.g. `'DeferredUIEnter'`, `'BufReadPost'`, `'CmdlineEnter'`) |
| `cmd` | `string \| string[]` | Load on command (e.g. `'Oil'`, `'GrugFar'`) |
| `ft` | `string \| string[]` | Load on filetype (e.g. `'markdown'`, `'lua'`) |
| `keys` | `table \| fun()` | Keymaps that trigger loading or register with which-key |
| `colorscheme` | `string` | Colorscheme name that triggers loading |
| `load_before` | `string \| string[]` | Loads this plugin before the target plugin(s) load (via custom handler) |
| `on_require` | `string \| string[]` | Loads this plugin when any module prefixes are required (via custom handler) |
| `before` | `fun()` | Executed before plugin is loaded (useful for global variables) |
| `after` | `fun(plugin)` | Executed after plugin is loaded (auto-defaults to `.setup(plugin.opts)` if omitted) |
| `opts` | `table \| fun()` | Options table or deferred builder function, deep-merged across all specs |
| `specs` | `table` | Child specs merged into other target plugins (LazyVim-style) |
| `optional` | `boolean` | If true, only applies if target plugin is explicitly enabled/installed |

---

## Handlers & Auto-Requiring Architecture

This configuration uses a layered strategy for dependency loading and on-demand requires:

1. **`load_before` (Inter-plugin Dependency Ordering)**:
   - Defined in `lua/config/load_before.lua`.
   - Used when Plugin A must be loaded and initialized before Plugin B starts loading.
   - Example: `harpoon2` (`load_before = { 'harpoon-lualine' }`) &rarr; `harpoon-lualine` (`load_before = { 'lualine.nvim' }`) &rarr; `lualine.nvim`.

2. **`on_require` (Explicit Fast-Path Module Loading)**:
   - Defined in `lua/config/on_require.lua`.
   - Used for common shared dependencies in `lua/plugins/common.lua` (`plenary`, `nui`, `nio`).
   - Resolves modules in-memory with zero disk/filesystem scanning overhead.

3. **`lzn-auto-require` (Filesystem Fallback Scanner)**:
   - Sourced via `require('lzn-auto-require').enable()` in `init.lua`.
   - Scans `packpath` for `opt/<plugin>/lua/<module>.lua` when an undeclared module is required.

---

## Complex Real-World Examples

### 1. Direct Module `require()` via `on_require`
Any plugin declared with `on_require` can be required directly from an `after` hook, keymap, command, or autocmd. No manual `trigger_load` is needed:

```lua
-- In lua/plugins/common.lua:
{ 'plenary.nvim', on_require = { 'plenary' } },

-- In lua/plugins/codecompanion.lua:
after = function()
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

### 3. Flake-Parts Style Modular Architecture (`lua/plugins/snacks/`)
For modular suites like `snacks.nvim`, each file in `lua/plugins/snacks/*.lua` is a standalone declarative spec returning:

```lua
-- lua/plugins/snacks/picker.lua
return {
  'snacks.nvim',
  keys = {
    { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent Files' },
  },
  opts = {
    picker = {
      sources = { ... },
    },
  },
}
```

`lua/plugins/snacks/init.lua` dynamically auto-scans all files in `lua/plugins/snacks/**`:
- Every modular spec (`git.lua`, `picker.lua`, `explorer.lua`, `dashboard.lua`, `terminal.lua`, `ui.lua`, etc.) declares its own scoped `keys` and `opts`.
- All keymaps across files are accumulated into `snacks.nvim` (over 75 keymaps active).
- All options are deep-merged using `Util.merge`.

### 4. LazyVim-Style Cross-Plugin Spec Merging (`specs = { ... }`)
Any plugin file can declare `specs = { ... }` to inject options, keymaps, or actions into another plugin without modifying that plugin's source file:

```lua
-- lua/plugins/flash.lua
return {
  'flash.nvim',
  event = 'DeferredUIEnter',
  opts = { ... },
  keys = { ... },

  -- Inject picker keymaps & flash jump action into snacks.nvim picker:
  specs = {
    {
      'snacks.nvim',
      opts = {
        picker = {
          win = {
            input = {
              keys = {
                ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
                ['s'] = { 'flash' },
              },
            },
          },
          actions = {
            flash = function(picker)
              require('flash').jump({
                pattern = '^',
                label = { after = { 0, 0 } },
                search = {
                  mode = 'search',
                  exclude = {
                    function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list' end,
                  },
                },
                action = function(match)
                  local idx = picker.list:row2idx(match.pos[1])
                  picker.list:_move(idx, true, true)
                end,
              })
            end,
          },
        },
      },
    },
  },
}
```

### 5. Session Management & Bufferline Pinned Buffers Persistence
Pinned buffers in `bufferline.nvim` (`<leader>bp`) are saved to `vim.g.BufferlinePinnedBuffers`.

To ensure pinned buffers persist across restarts and sessions:
1. `vim.opt.sessionoptions` in `lua/config/options.lua` includes `'globals'` so that `BufferlinePinnedBuffers` is written to session files.
2. `lua/plugins/bufferline.lua` listens to both `SessionLoadPost` and `User PersistenceLoadPost` to automatically restore pinned tabs whenever sessions are restored (`<leader>qs`, `<leader>ql`, `<leader>qS` via `persistence.nvim`).

### 6. Sourcing `after/` Directories with `rtp.nvim` (`Util.load_with_after`)
On NixOS, Neovim plugins live in individual `/nix/store/...` derivations rather than a monolithic `packpath`. Using [`rtp.nvim`](https://github.com/lumen-oss/rtp.nvim), `Util.load_with_after(plugin_name)` triggers `lz.n` loading and sources the plugin's `after/plugin/*.lua` scripts directly from its Nix store path:

```lua
-- In any after hook or custom loader:
Util.load_with_after('octo.nvim')
```

---

## LSP Configuration

Language servers are enabled in `lua/plugins/lsp.lua` via Neovim's native `vim.lsp.enable(server)`. Neovim automatically creates `FileType` autocommands to attach servers when matching buffers are opened. Server-specific configurations are stored in `lsp/<server>.lua` and merged automatically.
