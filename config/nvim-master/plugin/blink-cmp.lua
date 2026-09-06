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
      -- Reference https://cmp.saghen.dev/configuration/reference.html#completion-trigger
      preset = 'default',

      ['<C-Tab>'] = { 'select_and_accept' },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = 'inherit',
      },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          auto_show = function() return vim.fn.getcmdtype() == ':' end,
        },
        ghost_text = { enabled = true },
      },
    },
    completion = {
      trigger = {
        -- When true, will prefetch the completion items when entering insert mode
        prefetch_on_insert = true,

        -- When false, will not show the completion window automatically when in a snippet
        show_in_snippet = true,

        -- When true, will show completion window after backspacing
        show_on_backspace = false,

        -- When true, will show completion window after backspacing into a keyword
        show_on_backspace_in_keyword = false,

        -- When true, will show the completion window after accepting a completion and then backspacing into a keyword
        show_on_backspace_after_accept = true,

        -- When true, will show the completion window after entering insert mode and backspacing into keyword
        show_on_backspace_after_insert_enter = true,

        -- When true, will show the completion window after typing any of alphanumerics, `-` or `_`
        show_on_keyword = true,

        -- When true, will show the completion window after typing a trigger character
        show_on_trigger_character = true,

        -- When true, will show the completion window after entering insert mode
        show_on_insert = false,

        -- LSPs can indicate when to show the completion window via trigger characters
        -- however, some LSPs (e.g. tsserver) return characters that would essentially
        -- always show the window. We block these by default.
        show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
        -- You can also block per filetype with a function:
        -- show_on_blocked_trigger_characters = function(ctx)
        --   if vim.bo.filetype == 'markdown' then return { ' ', '\n', '\t', '.', '/', '(', '['

        -- When both this and show_on_trigger_character are true, will show the completion window
        -- when the cursor comes after a trigger character after accepting an item
        show_on_accept_on_trigger_character = true,

        -- When both this and show_on_trigger_character are true, will show the completion window
        -- when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,

        -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
        -- the completion window when the cursor comes after a trigger character when
        -- entering insert mode/accepting an item
        show_on_x_blocked_trigger_characters = { "'", '"', '(' },
        -- or a function, similar to show_on_blocked_trigger_character,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
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
