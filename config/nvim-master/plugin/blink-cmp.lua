vim.pack.add({
  --- [[ Autocomplete Engine ]]
  { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1.*') },
  -- [[ Snippet Engine ]]
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
})
require('lazyload').on_vim_enter(function()
  local default_sources = { 'lsp', 'path', 'snippets', 'buffer' }

  -- See https://github.com/mikavilpas/blink-ripgrep.nvim
  -- See https://main.cmp.saghen.dev/configuration/reference.html
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  require('blink.cmp').setup({
    keymap = {
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-space>'] = { 'show' },
    },
    cmdline = {
      enabled = true,
      completion = {
        menu = { auto_show = true },
        ghost_text = { enabled = true },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },
      keymap = {
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
      },
    },
    completion = {
      trigger = {
        prefetch_on_insert = false,
        show_on_keyword = true,
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      documentation = { auto_show = true },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
      },
    },
    signature = { enabled = true },
    appearance = {
      kind_icons = require('icons').kinds,
    },
    sources = {
      default = default_sources,
      providers = {

        snippets = {
          opts = {
            friendly_snippets = true,
            search_paths = { vim.env.DOTFILES .. '/config/nvim/snippets' },
          },
        },
        markdown = {
          name = 'RenderMarkdown',
          module = 'render-markdown.integ.blink',
        },
      },
    },
  })
end)
