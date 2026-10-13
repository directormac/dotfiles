-- blink.cmp with colorful-menu renderers, luasnip, and cmp-cmdline.
return {
  { 'blink.lib', load_before = { 'blink.cmp' } },
  { 'blink.compat', load_before = { 'blink.cmp' } },
  { 'blink-cmp-dictionary', load_before = { 'blink.cmp' } },
  { 'blink-cmp-env', load_before = { 'blink.cmp' } },
  { 'blink-cmp-git', load_before = { 'blink.cmp' } },
  { 'blink-emoji.nvim', load_before = { 'blink.cmp' } },
  { 'blink-nerdfont.nvim', load_before = { 'blink.cmp' } },
  { 'blink-ripgrep.nvim', load_before = { 'blink.cmp' } },

  {
    'colorful-menu.nvim',
    load_before = { 'blink.cmp' },
  },

  {
    'blink.cmp',
    event = { 'BufReadPost', 'BufNewFile', 'CmdlineEnter' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-Tab>'] = { 'select_and_accept' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-k>'] = {}, -- Handled by Noice signature help
        -- Ripgrep is manual-only (see `sources.providers.ripgrep`) so it needs an
        -- explicit keymap to be reachable at all.
        -- ['<C-g>'] = { function(cmp) cmp.show({ providers = { 'ripgrep' } }) end },
      },
      appearance = {
        nerd_font_variant = 'mono',
        kind_icons = vim.tbl_map(vim.trim, Icons.kinds),
      },
      snippets = {
        preset = 'luasnip',
      },
      cmdline = {
        keymap = {
          preset = 'inherit',
        },
        enabled = true,
        completion = {
          ghost_text = { enabled = true },
          menu = {
            auto_show = true,
          },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == '/' or type == '?' then return { 'buffer' } end
          if type == ':' or type == '@' then return { 'cmdline' } end
          return {}
        end,
      },
      fuzzy = {
        -- The order here IS the priority: `exact` wins outright, then the fuzzy
        -- score (which is where every `score_offset` competes), then `sortText`.
        -- NOTE: `sources.default` order does not set priority -- provider ids are
        -- collected with `vim.tbl_keys`, so that order is arbitrary.
        sorts = {
          'exact',
          'score',
          'sort_text',
        },
      },
      signature = {
        enabled = false, -- Handled cleanly by Noice!
        window = {
          border = 'single',
        },
      },
      completion = {
        menu = {
          border = 'single',
          winblend = 0,
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            columns = { { 'kind_icon' }, { 'label', gap = 1 } },
            components = {
              label = {
                width = { fill = true, max = 60 },
                text = function(ctx)
                  local highlights_info = require('colorful-menu').blink_highlights(ctx)
                  if highlights_info ~= nil then
                    -- Or you want to add more item to label
                    return highlights_info.label
                  else
                    return ctx.label
                  end
                end,
                highlight = function(ctx)
                  local highlights = {}
                  local highlights_info = require('colorful-menu').blink_highlights(ctx)
                  if highlights_info ~= nil then highlights = highlights_info.highlights end
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                  end
                  -- Do something else
                  return highlights
                end,
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = 'single',
            winblend = 0,
          },
        },
      },
      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
          'lazydev',
          'env',
          'dictionary',
          'emoji',
          'nerdfont',
          'git',
        },
        providers = {
          -- `score_offset` is additive to the fuzzy score, so it can only shift a
          -- source relative to the spread of fuzzy scores. Negative values on the
          -- noise-generators below are the real fix -- they match almost any keyword.
          snippets = {
            score_offset = 20,
            min_keyword_length = 3,
            should_show_items = function(ctx) return ctx.trigger.initial_kind ~= 'trigger_character' end,
          },
          path = {
            score_offset = 25,
          },
          lsp = {
            score_offset = 40,
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 30,
          },
          buffer = {
            score_offset = -10,
          },
          env = {
            name = 'Env',
            module = 'blink-cmp-env',
            score_offset = 5,
            opts = {
              show_braces = false,
              show_documentation_window = true,
            },
          },
          -- https://github.com/mikavilpas/blink-ripgrep.nvim#full-config
          ripgrep = {
            name = 'Grep',
            module = 'blink-ripgrep',
            -- Deliberately NOT in `sources.default`: searching the whole project on
            -- every keystroke is too expensive. Type `<C-g>` to open it manually.
            -- To re-enable it automatically, add 'ripgrep' to `sources.default`.
            score_offset = -30,
            min_keyword_length = 4,
            async = true,
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              prefix_min_len = 4,
              -- Requires snacks.nvim, which is already loaded.
              toggles = {
                on_off = '<leader>tg',
              },
              backend = {
                use = 'gitgrep-or-ripgrep',
              },
            },
          },
          -- TODO: Needs more configuration
          -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/
          dictionary = {
            name = 'Dictionary',
            module = 'blink-cmp-dictionary',
            score_offset = 10,
            min_keyword_length = 3,
          },
          emoji = {
            name = 'Emoji',
            module = 'blink-emoji',
            score_offset = -40,
            min_keyword_length = 3,
          },
          nerdfont = {
            name = 'Nerd Fonts',
            module = 'blink-nerdfont',
            score_offset = -45,
            min_keyword_length = 3,
          },
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
            -- only enable this source when filetype is gitcommit, markdown, or 'octo'
            enabled = function() return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype) end,
            --- @module 'blink-cmp-git'
            --- @type blink-cmp-git.Options
            opts = {},
          },
        },
      },
    },
  },
}
