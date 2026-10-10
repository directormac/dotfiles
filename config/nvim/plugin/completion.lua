-- blink.cmp with the colorful-menu renderers and cmp-cmdline for the command line.
nixInfo.lze.load({
  {
    'blink.cmp',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function(_)
      require('blink.cmp').setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = {
          preset = 'default',
        },
        appearance = {
          nerd_font_variant = 'mono',
          kind_icons = vim.tbl_map(vim.trim, require('config.icons').kinds),
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
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
                  highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        sources = {
          default = { 'lsp', 'path', 'buffer', 'omni' },
          providers = {
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
    'cmp-cmdline',
    auto_enable = true,
    on_plugin = { 'blink.cmp' },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    'blink.compat',
    auto_enable = true,
    dep_of = { 'cmp-cmdline' },
  },
  {
    'colorful-menu.nvim',
    auto_enable = true,
    on_plugin = { 'blink.cmp' },
  },
})
