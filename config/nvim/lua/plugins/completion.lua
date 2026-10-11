-- blink.cmp with colorful-menu renderers, luasnip, and cmp-cmdline.
return {
  {
    'blink.cmp',
    event = { 'DeferredUIEnter' },
    before = function()
      require('lz.n').trigger_load({
        'friendly-snippets',
        'luasnip',
        'blink.compat',
        'cmp-cmdline',
        'colorful-menu.nvim',
        'blink-ripgrep.nvim',
        'blink-emoji.nvim',
        'blink-cmp-env',
        'blink-cmp-dictionary',
        'blink-nerdfont.nvim',
      })
    end,
    after = function(_)
      local item_kinds = require('blink.cmp.types').CompletionItemKind
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
          ['<C-Tab>'] = { 'select_and_accept' },
          ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<CR>'] = { 'accept', 'fallback' },
          ['<C-k>'] = {}, -- Handled by Noice signature help
        },
        appearance = {
          nerd_font_variant = 'mono',
          kind_icons = vim.tbl_map(vim.trim, require('config.icons').kinds),
        },
        snippets = {
          preset = 'luasnip',
        },
        cmdline = {
          enabled = true,
          completion = {
            ghost_text = { enabled = true },
            menu = {
              auto_show = true,
            },
          },
          sources = {
            default = function()
              local type = vim.fn.getcmdtype()
              if type == '/' or type == '?' then return { 'buffer' } end
              if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
              return {}
            end,
          },
        },
        fuzzy = {
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
            'ripgrep',
            'dictionary',
            'emoji',
            'nerdfont',
          },
          providers = {
            snippets = {
              score_offset = 30,
            },
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            lazydev = {
              name = 'lazydev',
              module = 'lazydev.integrations.blink',
              score_offset = 45,
            },
            env = {
              name = 'Env',
              module = 'blink-cmp-env',
              score_offset = 20,
              opts = {
                item_kind = item_kinds.Variable,
                show_braces = false,
                show_documentation_window = true,
              },
            },
            -- https://github.com/mikavilpas/blink-ripgrep.nvim#full-config
            ripgrep = {
              name = 'Grep',
              module = 'blink-ripgrep',
              score_offset = 10,
            },
            -- TODO: Needs more configuration
            -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/
            dictionary = {
              name = 'Dictionary',
              module = 'blink-cmp-dictionary',
              score_offset = 15,
              min_keyword_length = 3,
            },
            emoji = {
              name = 'Emoji',
              module = 'blink-emoji',
              score_offset = 20,
            },
            nerdfont = {
              name = 'Nerd Fonts',
              module = 'blink-nerdfont',
              score_offset = 20,
            },
            -- spell = {
            --   name = 'spell',
            --   module = 'blink-cmp-spell',
            --   score_offset = 5,
            -- },
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
          },
        },
      })
    end,
  },
  {
    'luasnip',
    lazy = true,
    after = function(_)
      local luasnip = require('luasnip')
      luasnip.config.set_config({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
      })
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
  { 'blink.compat', lazy = true },
  { 'blink.lib', lazy = true },
  {
    'colorful-menu.nvim',
    lazy = true,
    after = function() require('colorful-menu').setup() end,
  },
  { 'friendly-snippets', lazy = true },

  { 'blink-ripgrep.nvim', lazy = true },
  { 'blink-cmp-dictionary', lazy = true },
  { 'blink-emoji.nvim', lazy = true },
  { 'blink-cmp-env', lazy = true },
  { 'blink-nerdfont.nvim', lazy = true },
  { 'cmp-cmdline', lazy = true },
}
