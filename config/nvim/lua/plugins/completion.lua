-- blink.cmp with colorful-menu renderers, luasnip fast-trigger, and cmp-cmdline.
local trigger_text = ';'

return {
  { 'blink.lib', load_before = { 'blink.cmp' } },
  { 'blink.compat', load_before = { 'blink.cmp' } },
  { 'blink-copilot', load_before = { 'blink.cmp' }, on_require = { 'blink-copilot' } },
  { 'blink-cmp-dictionary', load_before = { 'blink.cmp' }, on_require = { 'blink-cmp-dictionary' } },
  { 'blink-cmp-env', load_before = { 'blink.cmp' }, on_require = { 'blink-cmp-env' } },
  { 'blink-cmp-git', load_before = { 'blink.cmp' }, on_require = { 'blink-cmp-git' } },
  { 'blink-emoji.nvim', load_before = { 'blink.cmp' }, on_require = { 'blink-emoji' } },
  { 'blink-nerdfont.nvim', load_before = { 'blink.cmp' }, on_require = { 'blink-nerdfont' } },
  { 'blink-ripgrep.nvim', load_before = { 'blink.cmp' }, on_require = { 'blink-ripgrep' } },

  {
    'colorful-menu.nvim',
    load_before = { 'blink.cmp' },
    on_require = { 'colorful-menu' },
  },

  {
    'blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    -- before = function()
    --   nixInfo.lze.trigger_load({
    --     'blink.lib',
    --     'blink.compat',
    --     'blink-copilot',
    --     'blink-cmp-dictionary',
    --     'blink-cmp-env',
    --     'blink-cmp-git',
    --     'blink-emoji.nvim',
    --     'blink-nerdfont.nvim',
    --     'blink-ripgrep.nvim',
    --   })
    -- end,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        local ft = vim.bo[0].filetype
        if ft == 'snacks_picker_input' or ft == 'TelescopePrompt' or ft == 'minifiles' or ft == 'dap-repl' then
          return false
        end
        return true
      end,
      keymap = {
        preset = 'default',
        ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
        ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
        ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
        ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
        ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
        ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
        ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
        ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
        ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
        ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
        ['<C-Tab>'] = { 'select_and_accept' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-k>'] = {}, -- Handled by Noice signature help
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-g>'] = { function(cmp) cmp.show({ providers = { 'ripgrep' } }) end },
      },
      appearance = {
        nerd_font_variant = 'mono',
        kind_icons = vim.tbl_map(vim.trim, Utils.icons.kinds),
      },
      snippets = {
        preset = 'luasnip',
      },
      cmdline = {
        keymap = {
          preset = 'inherit',
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
          ['<C-y>'] = { 'select_and_accept' },
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
        },
      },

      completion = {
        menu = {
          border = 'single',
          winblend = 0,
          draw = {
            columns = { { 'kind_icon' }, { 'label', gap = 1 }, { 'kind' }, { 'source_name' } },
            components = {
              label = {
                width = { fill = true, max = 60 },
                text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
                highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
              },
              source_name = {
                width = { max = 10 },
                text = function(ctx) return '[' .. ctx.source_name .. ']' end,
                highlight = 'BlinkCmpGhostText',
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
        per_filetype = { org = { inherit_defaults = true, 'org' } },
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
          'copilot',
        },
        providers = {
          -- Fast snippet trigger with ';' character prefix.
          -- Snippets are hidden during standard coding to avoid polluting LSP completions,
          -- and appear instantly upon typing ';' at start-of-line or after whitespace/delimiters.
          snippets = {
            score_offset = 85,
            min_keyword_length = 0,
            override = {
              get_trigger_characters = function() return { trigger_text } end,
            },
            should_show_items = function(ctx)
              local col = ctx and ctx.cursor and ctx.cursor[2] or vim.api.nvim_win_get_cursor(0)[2]
              local line = ctx and ctx.line or vim.api.nvim_get_current_line()
              local before_cursor = line:sub(1, col)
              return before_cursor:match('^%s*' .. trigger_text .. '%w*$') ~= nil
                or before_cursor:match('[%s%({%[]' .. trigger_text .. '%w*$') ~= nil
            end,
            transform_items = function(_, items)
              local line = vim.api.nvim_get_current_line()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              local before_cursor = line:sub(1, col)
              local start_pos, end_pos = before_cursor:find(trigger_text .. '[^' .. trigger_text .. ']*$')
              if start_pos then
                for _, item in ipairs(items) do
                  if not item.trigger_text_modified then
                    ---@diagnostic disable-next-line: inject-field
                    item.trigger_text_modified = true
                    item.textEdit = {
                      newText = item.insertText or item.label,
                      range = {
                        start = { line = vim.fn.line('.') - 1, character = start_pos - 1 },
                        ['end'] = { line = vim.fn.line('.') - 1, character = end_pos },
                      },
                    }
                  end
                end
              end
              return items
            end,
          },
          path = {
            score_offset = 25,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
              show_hidden_files_by_default = true,
            },
          },
          lsp = {
            score_offset = 40,
            should_show_items = function(ctx)
              -- Suppress LSP if user is triggering snippets with ';'
              if ctx.trigger.character == trigger_text then return false end
              -- Suppress LSP if user is typing ':' at start of line or after space (emoji/nerdfont trigger)
              if ctx.trigger.character == ':' then
                local col = ctx.cursor[2]
                local before_colon = ctx.line:sub(1, col - 1)
                if before_colon:match('^%s*$') or before_colon:match('%s$') then return false end
              end
              return true
            end,
          },
          buffer = {
            score_offset = -10,
          },
          copilot = {
            name = 'Copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
            ---@module 'blink-copilot'
            ---@type blink-copilot.Config
            opts = {
              max_completions = 3,
              max_attempts = 4,
              debounce = 200,
              auto_refresh = {
                backward = true,
                forward = true,
              },
            },
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            enabled = function()
              return vim.tbl_contains({
                'lua',
              }, vim.bo.filetype)
            end,
            score_offset = 30,
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
            score_offset = -30,
            min_keyword_length = 4,
            async = true,
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              prefix_min_len = 4,
              toggles = {
                on_off = '<leader>tg',
              },
              backend = {
                use = 'gitgrep-or-ripgrep',
              },
            },
          },
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
            score_offset = 95,
            min_keyword_length = 0,
            opts = { insert = true },
          },
          nerdfont = {
            name = 'Nerd Fonts',
            module = 'blink-nerdfont',
            score_offset = 90,
            min_keyword_length = 0,
            opts = { insert = true },
          },
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
            enabled = function()
              return vim.tbl_contains({
                'octo',
                'gitcommit',
                'markdown',
              }, vim.bo.filetype)
            end,
            --- @module 'blink-cmp-git'
            --- @type blink-cmp-git.Options
            opts = {},
          },
          org = { name = 'Org', module = 'org.completion.blink' },
        },
      },
    },
  },
}
