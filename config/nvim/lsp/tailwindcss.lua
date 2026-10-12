---@brief
--- tailwindcss settings.
---
--- Restricts tailwindcss filetypes to languages relevant to this dotfiles setup
--- and suppresses checkhealth warnings for unused templating engines.
return {
  filetypes = {
    'html',
    'css',
    'scss',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'svelte',
    'astro',
    'vue',
    'heex',
    'elixir',
  },
}
