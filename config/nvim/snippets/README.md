# Snippets Guide

This directory contains custom user snippets managed by [LuaSnip](https://github.com/L3MON4D3/LuaSnip) and served through [blink.cmp](https://github.com/Saghen/blink.cmp) in [`lua/plugins/completion.lua`](../lua/plugins/completion.lua).

---

## Architecture Overview

```
                      ┌───────────────────────────────────────────────┐
                      │                   blink.cmp                   │
                      │             (sources: 'snippets')             │
                      └───────────────────────┬───────────────────────┘
                                              │ queries
                                              ▼
                      ┌───────────────────────────────────────────────┐
                      │                    LuaSnip                    │
                      └───────────────┬───────────────┬───────────────┘
                                      │               │
                 ┌────────────────────┴──┐         ┌──┴────────────────────┐
                 ▼                       ▼         ▼                       ▼
    ┌─────────────────────────┐  ┌─────────────┐ ┌───────────────────┐ ┌─────────────────┐
    │    friendly-snippets    │  │ package.json│ │   custom JSON     │ │   custom Lua    │
    │ (from_vscode.lazy_load) │  │  (manifest) │ │ (from_vscode)     │ │   (from_lua)    │
    │   [system / nix store]  │  │             │ │ *.json            │ │ *.lua           │
    └─────────────────────────┘  └─────────────┘ └───────────────────┘ └─────────────────┘
```

1. **`friendly-snippets`**: Prepackaged community snippet collection provided via Nix and loaded automatically from Neovim's `runtimepath`.
2. **Custom VS Code JSON Snippets**: Any `*.json` file declared in [`package.json`](./package.json).
3. **Custom LuaSnip Lua Snippets**: Any `<filetype>.lua` file in this directory loaded via `luasnip.loaders.from_lua`.

---

## 1. Adding VS Code Format Snippets (`.json`)

VS Code format is ideal for standard text expansions, multi-line templates, and porting snippets from other editors.

### Step 1: Add or edit snippet files

Create or edit `<filetype>.json` (or `all.json` for snippets available in every buffer):

```json
{
  "Snippet Name": {
    "prefix": "trigger",
    "body": [
      "local ${1:var} = ${2:default_value}",
      "$0"
    ],
    "description": "Short explanation of the snippet"
  }
}
```

### Snippet Syntax Reference

| Syntax | Example | Description |
| --- | --- | --- |
| **Tabstops** | `$1`, `$2`, `$0` | Jump positions with `<Tab>`. `$0` is the final exit point. |
| **Placeholders** | `${1:default_value}` | Pre-filled editable value. Can be nested: `${1:another_${2:val}}`. |
| **Choices** | `${1\|apple,banana,orange\|}` | Enumerated dropdown list of choices. |
| **Variables** | `$CURRENT_YEAR`, `$TM_FILENAME` | Dynamically inserted values (dates, filenames, clipboard, etc.). |
| **Transforms** | `${TM_FILENAME/(.*)\\..+$/$1/}` | Regex replacements on variables or tabstops. |

#### Commonly Used Variables

- `$CURRENT_YEAR`, `$CURRENT_MONTH`, `$CURRENT_DATE`
- `$CURRENT_HOUR`, `$CURRENT_MINUTE`, `$CURRENT_SECOND`
- `$TM_FILENAME`, `$TM_FILENAME_BASE`
- `$CLIPBOARD`
- `$WORKSPACE_NAME`

### LuaSnip Extensions in JSON

LuaSnip adds an optional `"luasnip"` key to snippet objects:

```json
{
  "Autotriggered Snippet": {
    "prefix": ";;date",
    "body": "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
    "description": "Expands instantly without pressing completion key",
    "luasnip": {
      "autotrigger": true,
      "priority": 2000,
      "wordTrig": false
    }
  }
}
```

- `autotrigger` (`boolean`): Automatically expands when `prefix` is typed.
- `priority` (`number`): Higher priority snippets rank first (default: `1000`).
- `wordTrig` (`boolean`): If `false`, expands even when attached to other characters.

### Step 2: Register in `package.json`

> [!IMPORTANT]
> **LuaSnip requires new `.json` files to be explicitly registered in [`package.json`](./package.json)**.
> Without an entry in `contributes.snippets`, LuaSnip will ignore the file.

Open [`package.json`](./package.json) and add an entry:

```json
{
  "language": ["rust"],
  "path": "./rust.json"
}
```

For snippets available across all languages (like `all.json` or `global.json`), use `"language": ["all"]`.

---

## 2. Adding LuaSnip Native Snippets (`.lua`)

Lua format allows programmable snippets with Lua functions, dynamic trees, and conditional logic.

### How it works
Any `<filetype>.lua` file placed in this directory (e.g. `lua.lua`, `python.lua`, `all.lua`) is automatically loaded by `require('luasnip.loaders.from_lua').lazy_load()`. **No `package.json` entry is required for `.lua` files.**

### File Structure

Create `snippets/<filetype>.lua`:

```lua
local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

return {
  -- Basic snippet: trigger 'shebang'
  s('shebang', {
    t('#!/usr/bin/env '),
    i(1, 'bash'),
    t({ '', '' }),
    i(0),
  }),

  -- Dynamic snippet using a Lua function
  s('filename', {
    f(function()
      return vim.fn.expand('%:t')
    end),
  }),

  -- Choice node snippet: cycle choices with choice keymaps
  s('log', {
    t('console.'),
    c(1, {
      t('log'),
      t('warn'),
      t('error'),
      t('debug'),
    }),
    t('('),
    i(2, 'msg'),
    t(');'),
  }),
}
```

### Lua Node Types

| Node | Function | Purpose |
| --- | --- | --- |
| `t("text")` | Text Node | Literal immutable text. Pass table for multi-line: `t({ "line 1", "line 2" })`. |
| `i(1, "default")` | Insert Node | Editable tabstop. First arg is index, second is optional default text. |
| `f(fn, {deps})` | Function Node | Evaluates a Lua function. Receives text from dependent nodes. |
| `c(1, { ... })` | Choice Node | Offers multiple node variations at the same tabstop. |
| `sn(nil, { ... })`| Snippet Node | Encapsulates a group of nodes inside dynamic/choice nodes. |
| `d(1, fn, {deps})`| Dynamic Node | Dynamically returns a `snippet_node` based on previous input. |

---

## 3. Working with `friendly-snippets`

- **Inspection & Triggers**: You can browse the triggers and snippets provided by `friendly-snippets` on the [friendly-snippets documentation site](https://github.com/rafamadriz/friendly-snippets/tree/main/snippets) or by searching in Neovim completion.
- **Overriding & Shadowing**: If your custom snippet shares the exact same `prefix` as a friendly-snippet, both will appear in the completion menu. To ensure your custom snippet takes precedence, add `"luasnip": { "priority": 2000 }` to give it a higher score offset.

---

## 4. Keymaps & Completion Integration

Configured in [`lua/plugins/completion.lua`](../lua/plugins/completion.lua):

| Key | Mode | Action |
| --- | --- | --- |
| `<Tab>` | Insert | Select next item, jump to next snippet tabstop (`snippet_forward`) |
| `<S-Tab>` | Insert | Select previous item, jump to previous snippet tabstop (`snippet_backward`) |
| `<CR>` | Insert | Accept completion item / expand snippet |
| `<C-Tab>` | Insert | Select and accept snippet |

---

## References & Official Docs

- [VS Code Snippet Specifications](https://code.visualstudio.com/docs/editor/userdefinedsnippets)
- [LuaSnip Documentation (`:help luasnip`)](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md)
- [LuaSnip Loaders Reference](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders)
- [friendly-snippets Repository](https://github.com/rafamadriz/friendly-snippets)
- [blink.cmp Documentation](https://cmp.saghen.dev/configuration/snippets.html)
