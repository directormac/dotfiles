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
      })
    end,
    after = function(_)
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
          ['<C-Tab>'] = { 'select_and_accept' },
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
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            if type == '/' or type == '?' then return { 'buffer' } end
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            'exact',
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            border = 'single',
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              columns = { { 'kind_icon' }, { 'label', gap = 1 } },
              components = {
                label = {
                  width = { fill = true, max = 60 },
                  text = function(ctx)
                    local highlights_info = require('colorful-menu').blink_highlights(ctx)
                    if highlights_info ~= nil then
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
              border = 'rounded',
            },
          },
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', 'omni' },
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
  { 'cmp-cmdline', lazy = true },
  { 'blink.compat', lazy = true },
  { 'colorful-menu.nvim', lazy = true },
  { 'friendly-snippets', lazy = true },
}
