# Neovim configuration

This directory is a plain Neovim runtime directory (a `runtimepath` entry), but it is
**not** installed into `~/.config/nvim`. It is copied into the Nix store by
[`nixos/modules/apps/neovim.nix`](../../nixos/modules/apps/neovim.nix) through
`settings.config_directory`, which the wrapper (`nix-wrapper-modules`, module
`neovim`) prepends to both `runtimepath` and `packpath`, plus `<config>/after` at the
end. `stdpath('config')` is blocked (`block_normal_config = true`), so `~/.config/nvim`
is completely ignored.

Consequences you can rely on:

| Directory | Sourced | Use it for |
| --- | --- | --- |
| `init.lua` | `dofile`'d by the wrapper (`INIT_MAIN` spec) | ordering only |
| `lua/**` | never automatically, only `require()` | modules + spec tables (bytecode cached by `vim.loader`) |
| `plugin/*.lua` | after `init.lua`, before `VimEnter` | editor globals/autocmds with no plugin dependency |
| `ftplugin/<ft>.lua` | on `FileType=<ft>` | per-filetype tweaks |
| `lsp/<server>.lua` | merged into `vim.lsp.config('<server>')` when the client starts | LSP server settings (see `after/lsp/` below) |
| `queries/**` | by treesitter | query additions (see Treesitter below) |
| `after/{plugin,ftplugin,lsp,syntax}/**` | last | override anything, including plugin-provided `lsp/*.lua` |

Because the config dir is prepended, anything you put in `syntax/`, `indent/`,
`keymap/` or `lsp/` replaces the same file in `$VIMRUNTIME` and in plugins when it is
picked by name (`lsp/<name>.lua`, `<ft>/...`, `syntax/x.vim`).

## Translating a spec from lazy.nvim / lz.n

This config uses **lze** (via `nix-wrapper-modules` + `lzextras`), not lazy.nvim, and
Nix rather than `vim.pack.add` for installation. A lazy.nvim spec dropped in verbatim
loads nothing and reports no error, because lze ignores fields it has no handler for.
Translation:

| lazy.nvim / lz.n | lze here |
| --- | --- |
| `opts = { ... }` | `after = function() require('<module>').setup({ ... }) end` |
| `config = function(_, opts) ... end` | same `after` shape |
| `keys = { { '<leader>x', '<cmd>Foo<cr>', { desc = 'x' } } }` | `keys = { { '<leader>x', '<cmd>Foo<cr>', desc = 'x' } }` |
| `{ '<leader>x', '<cmd>Foo<cr>', desc = 'x' }` (flat tuple) | wrap it: `keys = { { ... } }` |
| `dependencies = { 'a/b' }` | `dep_of = { 'a.nvim' }` (only when it must load *before*) |
| an integration that `require`s its host | `on_plugin = { 'oil.nvim' }` — `dep_of` fires too early |
| `pkgs = { 'owner/repo' }` | works as-is: installed with `vim.pack` on VimEnter and packed with the spec, see *Adding a plugin* |
| `version`, `build`, `priority = 'high'`, `lazy = true` | `version`/`build`/`priority` do not exist; `lazy = true` is the default for children of a parent spec |
| `require('oil.nvim')` | `require('oil')` — the module name is rarely the plugin name |

Two ordering rules that bite most often:

* `desc` must be a **named field** of the key table (`{ lhs, rhs, desc = '...' }`). A
  nested `{ desc = ... }` as the third item is dropped, so the mapping appears with no
  description.
* `dep_of` runs the dependency's `after` hook from the dependent's `before` hook, i.e.
  **before** the dependent is packadd'd. If the dependency's setup needs the
  dependent's module (`oil-lsp-diagnostics` does `require('oil')` on line 1), you get
  `module 'oil' not found` — use `on_plugin` instead, which fires after.

## Layout

```
init.lua                     19 lines: vim.loader.enable() + 4 requires, nothing else
lua/bootstrap.lua            nixInfo, lze, the spec handlers (incl. `pkgs`), mapleader
lua/options.lua              vim.o / vim.opt / vim.wo
lua/keymaps.lua              global + clipboard maps
lua/pack.lua                 the `pkgs` handler: vim.pack install + VimEnter prune
lua/plugins.lua              the single nixInfo.lze.load call; auto-imports lua/plugins/
lua/plugins/*.lua            one module per plugin domain, each returns a LIST of specs
lua/lsp/init.lua             nvim-lspconfig spec + the shared vim.lsp.config('*') on_attach
lua/lsp/<lang>.lua           one trigger spec per language
lsp/<server>.lua             settings for one language server
plugin/editor.lua            netrw globals, formatoptions, yank highlight
ftplugin/*.lua               markdown, gitcommit
```

`lua/plugins/oil.lua` is the worked example of the three rules above: it configures three
plugins (`oil.nvim` plus the `oil-git` and `oil-lsp-diagnostics` integrations) using
`on_plugin`, and it is the spec to copy when translating one of your lazy.nvim files.

Every `lua/plugins/*.lua` module **returns a table of lze specs** and is discovered
automatically: `lua/plugins.lua` imports the whole directory with lzextras'
`mod_dir_to_spec('plugins')`, so a new spec file needs no other edits. `lua/lsp/*.lua`
stays an explicit import list — order matters there (the shared nvim-lspconfig spec
first, then the per-language triggers). Imports use `require()`, so these files get
`vim.loader` bytecode caching for free.

## Adding a plugin

Plugins come from two places. The hermetic core is installed by Nix (declared in
`nixos/modules/apps/neovim.nix` **and** in Lua). Anything else is installed at runtime
by `vim.pack` from a `pkgs` field — no Nix edit, no listing anywhere else. The most
common mistake on the Nix side is a name mismatch, see below.

### Via `vim.pack` (no Nix spec)

Drop a file in `lua/plugins/` — the directory is auto-discovered:

```lua
-- config/nvim/lua/plugins/tuxedo.lua
return {
  'tuxedo',
  pkgs = {
    'IogaMaster/tuxedo.nvim',
  },
  keys = {
    { '<leader>tt', '<cmd>Tuxedo<cr>', desc = 'Task Management' },
  },
}
```

* `pkgs` takes `owner/repo` shorthand or full URLs. The plugin itself goes in the list;
  dependencies go in the same list — they are packadd'd together with the spec.
* The spec name does not need to match the directory name: the `pkgs` directories are
  packed first, and a `packadd` of a missing directory is silent.
* Installed once on `VimEnter` (`confirm = false`, `load = false` — so lazy loading
  still works), and on demand if a trigger fires first. Never *updated* automatically:
  run `:lua vim.pack.update()` and review the confirmation buffer.
* The lockfile (`~/.config/nvim/nvim-pack-lock.json`) pins installed revisions; the
  plugins themselves live in `stdpath('data')/site/pack/core/opt`.
* When a spec disappears, its plugin is deleted from disk on the next start. Only
  `vim.pack`-managed plugins are ever pruned; the Nix packdir is untouched.
* No `auto_enable` on a pkgs spec — Nix never installed it, so the spec would disable
  itself. And don't declare the same plugin on both sides: two copies on the runtimepath.
* Give pkgs specs a normal trigger (`keys`, `ft`, `cmd`, ...). A non-lazy one installs
  synchronously during `init.lua` on the very first run.

### Already in nixpkgs

```nix
# nixos/modules/apps/neovim.nix
config.specs.fzf = {
  data = with pkgs.vimPlugins; fzf-vim;
  lazy = true;                                # without this it lands in start/
};
```

```lua
-- config/nvim/lua/plugins/editing.lua (inside the returned list)
{ 'fzf-vim', auto_enable = true, event = 'InsertEnter', cmd = { 'FzfLua' } },
```

### Not in nixpkgs

Add a flake input with `flake = false`, then use `nvim-lib.mkPlugin`:

```nix
# nixos/flake.nix
inputs.plugins-fzf-lua = {
  url = "github/ibhagwan/fzf-lua";
  flake = false;
};

# nixos/modules/apps/neovim.nix
config.specs.fzf-lua = config.nvim-lib.mkPlugin "fzf-lua" inputs.plugins-fzf-lua;
```

The first argument is the name of the plugin directory that will be created, so it must
match your Lua spec name.

### The name must match

lze's default loader is `vim.cmd.packadd(name)`, which looks for
`pack/myNeovimPackages/{opt,start}/<name>`. The directory name comes from the Nix side
(`pname` of the derivation), **not** from your Lua spec. So:

* `pkgs.vimPlugins["blink-cmp"]` → directory `blink.cmp` → spec name must be `blink.cmp`
* `pkgs.vimPlugins["catppuccin-nvim"]` → directory `catppuccin-nvim`
* `pkgs.vimPlugins["vim-sleuth"]` → directory `vim-sleuth`

Check what is actually installed, at any time:

```vim
:lua print(vim.inspect(vim.tbl_keys(nixInfo.plugins.lazy)))    -- opt/ (lazy)
:lua print(vim.inspect(vim.tbl_keys(nixInfo.plugins.start)))   -- start/ (startup)
:lua print(vim.inspect(nixInfo.get_nix_plugin_path('blink.cmp')))
```

`nixInfo.plugins` is the table the info plugin was built from; if a plugin is missing
there, it is not in the packdir and `auto_enable` will disable its spec.

### lazy vs startup

A spec's default is `parentSpec.lazy or false`, so a child of `specs.general` inherits
`lazy = true` from it. That puts the plugin in `pack/.../opt/`, which means it is **not**
on the runtimepath until something triggers it. Give every lazy spec a trigger lze
understands:

| Field | Triggers on |
| --- | --- |
| `event = 'VimEnter'` | that autocmd |
| `ft = 'lua'` | that filetype |
| `cmd = { 'Foo' }` | that command |
| `keys = { { '<leader>ff' } }` | that mapping |
| `colorscheme = 'catppuccin'` | `:colorscheme` with that name |
| `dep_of = { 'other' }` | when `other` loads |
| `on_plugin = { 'other' }` | when `other` loads |

Use `lazy = false` for plugins that must be on the runtimepath during startup
(`snacks.nvim`, `nvim-treesitter`, the nix-only entries).

### Nix-side-only entries

Inside a parent spec's `data = [ ... ]` list you may put a nameless entry to force the
Nix side into `start/` without creating an lze spec:

```nix
config.specs.general = {
  lazy = true;
  data = with pkgs.vimPlugins; [
    { data = vim-sleuth; lazy = false; }   -- Nix only: startup, no Lua spec needed
    snacks-nvim
  ];
};
```

## Adding a language server

Three places, plus one import line.

**1. Nix spec for the language** (gate + binaries):

```nix
# nixos/modules/apps/neovim.nix
config.specs.python = {
  data = null;                                -- required, see note below
  runtimePkgs = with pkgs; [ basedpyright ruff ];
};
```

`runtimePkgs` is a custom spec field declared in this repo (see the `specMods` block in
the wrapper module). Everything collected from it is appended to the wrapper's `PATH`, so
the server and any formatter/linter binary are available to Neovim and to `:!` calls.
Because it is *appended*, a binary also present in your system profile (e.g. `stylua`
from `environment.systemPackages`) will win — same version, but worth knowing.

**2. Trigger spec** (which filetype starts it):

```lua
-- config/nvim/lua/lsp/python.lua
return {
  {
    'basedpyright',
    for_cat = 'python',
    lsp = { filetypes = { 'python' } },
  },
}
```

**3. Server settings** (data, not code):

```lua
-- config/nvim/lsp/basedpyright.lua
return {
  settings = {
    basedpyright = { analysis = { typeCheckingMode = 'basic' } },
  },
}
```

**4. Register the import** in `lua/plugins.lua` (lsp imports stay explicit):

```lua
{ import = 'lsp.python' },
```

### Why settings live in `lsp/` and not in the spec

`:h lsp-config-merge` resolves a client config in this order (later wins):

1. the `'*'` config (our shared `on_attach`)
2. all `lsp/<server>.lua` on the runtimepath
3. all `after/lsp/<server>.lua` on the runtimepath
4. anything passed to `vim.lsp.config()` at runtime

lzextras' `lsp` handler calls `vim.lsp.config(name, spec.lsp)`, which lands in bucket 4 —
the highest priority. So anything you leave in `spec.lsp` silently overrides the
`lsp/*.lua` file. Keep `spec.lsp` for `filetypes` only, and put `settings` in the file.
The file basename must equal the spec name (`lsp/basedpyright.lua` for the spec named
`basedpyright`).

## Adding a formatter or linter

Binaries go in the language spec's `runtimePkgs`; the config goes in
`lua/plugins/editing.lua`:

```lua
conform.setup({
  formatters_by_ft = {
    lua = nixInfo(nil, 'settings', 'cats', 'lua') and { 'stylua' } or nil,
    python = { 'ruff_format', 'ruff_check' },
  },
})

require('lint').linters_by_ft = { python = { 'ruff' } }
```

## Spec gating: `auto_enable` and `for_cat`

Both are custom handlers registered in `lua/bootstrap.lua`.

* `auto_enable = true` disables the spec when Nix did not install that plugin, so the
  config still works when you use it outside Nix. It accepts `true`, a plugin name, or a
  list of names.
* `for_cat = '<name>'` disables the spec when the top-level Nix spec `specs.<name>` is not
  enabled. `settings.cats` in the info plugin is generated from `config.specs` for exactly
  this purpose. Note the Nix-side `data` field has no default, so a category-only spec
  must say `data = null;`.

## Reading Nix values from Lua

```lua
nixInfo('default', 'settings', 'colorscheme')        -- nixInfo.specs.colorscheme choice
nixInfo(false, 'settings', 'cats', 'lua')            -- is the `lua` spec enabled?
nixInfo(vim.v.progpath, 'progpath')                  -- absolute path of this wrapper
nixInfo.isNix                                        -- false when running outside Nix
```

To add a new Nix option, declare it under `options.settings.*` in
`nixos/modules/apps/neovim.nix`; anything in `settings` is serialised into the info
plugin and readable with `nixInfo(default, 'settings', 'yourkey')`.

## Treesitter

Grammars come from Nix, not from `:TSInstall`:

```nix
config.specs.general = {
  data = with pkgs.vimPlugins; [ nvim-treesitter.withAllGrammars ];
};
```

`collateGrammars` (default `true`) merges every grammar into a single
`start/COLLATED_TS_GRAMMARS` plugin, which cuts startup time. Put your own queries in
`config/nvim/queries/<lang>/`: treesitter concatenates the `*.scm` of every runtimepath
entry, with later entries *extending* earlier ones, so yours are added to the plugin's
rather than replacing them. Use `; inherits:` / `; extends` accordingly.

## Rebuilding

```bash
cd nixos
git add ../config/nvim        # IMPORTANT, see below
nix build .#neovim
./result/bin/neovim
```

**Untracked files never reach the store.** Nix copies a path from inside a Git repository
using the index, so a new file that is not `git add`ed is silently missing from the build
and you will get `module 'config.foo' not found`. Tracked files are read from the working
tree, so edits to already-tracked files do not need staging.

`nix develop` gives you `neovim` from `packages.nvim-dev`, a variant whose
`config_directory` is `vim.fn.stdpath('config')` for hot reload. It currently has no
config to load, because `~/.config/nvim` cannot be symlinked to this repo while
lazyvim-nix writes its own `~/.config/nvim/init.lua` (see the comment in
`nixos/modules/apps/neovim.nix`). Use `.#neovim` until that is resolved.

Formatting is stylua, driven by this directory's `.stylua.toml` (2 spaces, single
quotes) and wired into treefmt:

```bash
nix fmt
```

## Debugging

```vim
:messages                     : lze reports hook failures here as notifications
:scriptnames                  : proves plugin/, ftplugin/, colors/ were sourced
:checkhealth vim.lsp          : "Enabled Configurations" + resolvable servers
:lua print(vim.inspect(vim.tbl_keys(nixInfo.plugins.start)))
:lua print(vim.inspect(nixInfo.plugins))
```

| Symptom | Cause |
| --- | --- |
| `module 'config.x' not found` | file not staged, or not in `runtimepath` (should not happen: the dir is prepended) |
| `lze: Plugin <name> not found` | Lua spec name does not match the packdir name |
| `auto_enable` silently disabled a spec | plugin missing from `nixInfo.plugins` — check the Nix spec |
| `vim.pack install failed` / `could not install` in `:messages` | clone failed (no network, or no `git` on PATH) — restart to retry; nothing was pruned |
| pkgs spec does nothing | `auto_enable` disabled it, it has no trigger field, or it is also declared in Nix |
| spec loads but nothing happens | lazy spec with no trigger field |
| an `lsp/*.lua` setting seems ignored | the same key is still in `spec.lsp` (bucket 4 wins) |
| hook error with no traceback | `vim.schedule_wrap` in lze's `xpcall`; check `:messages` |

## Gotchas in this setup

* `require('catppuccin')`, not `require('catppuccin-nvim')` — the module name is not the
  plugin name. `require` of an unknown module is intercepted by lzextras' `on_require`
  handler and errors with `no plugin registered to load on require of ...`.
* A spec's `colorscheme` field takes the **colorscheme name** used by `:colorscheme`
  (`'catppuccin'`), not the plugin name. Neovim ships its own `colors/catppuccin.vim`, so
  a mismatch means `:colorscheme` succeeds and the plugin is never loaded.
* lualine themes are named after the flavour (`catppuccin-mocha`), not `catppuccin`.
  `theme = 'auto'` derives it from `colors_name`, which also follows `settings.colorscheme`.
* `require('conform')` and friends fail on purpose: lazy plugins are only requirable once
  their trigger has fired. Trigger them, or use the spec's `keys`/`event` field.
* `vim.loader.enable()` is on, so `require`d modules are byte-compiled. Files Neovim
  sources itself (`plugin/*.lua`, `ftplugin/*.lua`) are not, so keep them thin and push
  logic into `lua/`.