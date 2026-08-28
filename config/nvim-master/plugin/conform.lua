require('lazyload').on_vim_enter(function()
  vim.g.auto_format = true

  vim.pack.add({
    { src = 'https://github.com/stevearc/conform.nvim' },
  })

  require('conform').setup({
    format_on_save = function()
      if not vim.g.auto_format then return end
      return { timeout_ms = 5000, lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      elixir = { 'mix' },
      lua = { 'stylua' },
      proto = { 'buf' },
      sh = { 'shfmt' },
    },
    formatters = {
      biome = {
        args = { 'format', '--indent-style', 'space', '--stdin-file-path', '$FILENAME' },
      },
      gci = {
        args = { 'write', '--skip-generated', '-s', 'standard', '-s', 'default', '--skip-vendor', '$FILENAME' },
      },
      goimports = {
        args = { '-srcdir', '$FILENAME' },
      },
      golines = {
        -- golines runs gofumpt prior to running itself
        prepend_args = { '--base-formatter=gofumpt -extra', '--ignore-generated', '--tab-len=1', '--max-len=120' },
      },
      prettier = {
        prepend_args = { '--prose-wrap', 'always', '--print-width', '80', '--tab-width', '2' },
      },
      rumdl = {
        -- rumdl discovers rumdl.toml by walking up from the cwd, and matches
        -- per-file settings (e.g. per-file-flavor) against the file path. The
        -- default `rumdl fmt -` gives it neither, so a project's config is
        -- silently ignored -- which mangles e.g. mkdocs admonitions.
        cwd = function(_, ctx) return ctx.dirname end,
        prepend_args = {

          -- Fallback defaults for projects without a rumdl.toml of their own.
          -- MD034: leave bare URLs/emails untouched (no <...> wrapping).
          -- MD036: don't rewrite bold-only paragraphs (e.g. **Example:**) into
          -- level-2 headings.
          -- MD040: don't require or auto-fill fenced code block languages.
          '--config',
          'global.disable = ["MD034", "MD036", "MD040"]',
          '--config',
          'MD013.line-length = 80',
          '--config',
          'MD013.reflow = true',
        },
      },
      yamlfmt = {
        prepend_args = {
          '-formatter',
          'retain_line_breaks_single=true',
          '-formatter',
          'pad_line_comments=2',
        },
      },
    },
  })

  vim.keymap.set('n', '<leader>uf', function()
    vim.g.auto_format = not vim.g.auto_format
    vim.notify('Auto-format: ' .. (vim.g.auto_format and 'on' or 'off'))
  end, { desc = 'Toggle auto-format' })
end)

-- vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
--
-- require('conform').setup({
--   notify_on_error = false,
--   format_on_save = function(bufnr)
--     -- You can specify filetypes to autoformat on save here:
--     local enabled_filetypes = {
--       lua = true,
--       taplo = true,
--     }
--     if enabled_filetypes[vim.bo[bufnr].filetype] then
--       return { timeout_ms = 500 }
--     else
--       return nil
--     end
--   end,
--   default_format_opts = {
--     lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
--   },
--   -- You can also specify external formatters in here.
--   formatters_by_ft = {
--     lua = { 'stylua' },
--     toml = { 'taplo' },
--     -- rust = { 'rustfmt' },
--     -- Conform can also run multiple formatters sequentially
--     -- python = { "isort", "black" },
--     --
--     -- You can use 'stop_after_first' to run the first available formatter from the list
--     -- javascript = { "prettierd", "prettier", stop_after_first = true },
--   },
-- })
--
-- vim.keymap.set(
--   { 'n', 'v' },
--   '<leader>cf',
--   function() require('conform').format({ async = true }) end,
--   { desc = 'Format buffer.' }
-- )
