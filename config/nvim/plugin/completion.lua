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
            border = 'single',
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            -- border = 'rounded',
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
  {
    'friendly-snippets',
    auto_enable = true,
    dep_of = { 'luasnip' },
  },
  {
    'luasnip',
    auto_enable = true,
    dep_of = { 'blink.cmp' },
    after = function(_)
      local luasnip = require('luasnip')
      luasnip.config.set_config({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
      })
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
})
