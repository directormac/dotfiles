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
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      -- set to 'none' to disable the 'default' preset
      preset = 'default',
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
