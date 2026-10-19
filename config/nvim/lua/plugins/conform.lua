return {

  {
    'conform.nvim',
    on_require = { 'conform' },
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cF',
        function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end,
        mode = { 'n', 'x' },
        desc = 'Format Injected Langs',
      },
    },
    opts = {
      format_on_save = function()
        if not vim.g.auto_format then return end
        return { timeout_ms = 5000, lsp_format = 'fallback' }
      end,
      -- `treefmt` has `require_cwd = true` (looking for `.treefmt.toml` / `treefmt.toml`),
      -- so in repositories with treefmt it runs first and stops; elsewhere it is skipped
      -- and the language formatter runs. Keeping this in global config ensures formatting
      -- works in git worktrees even before `.nvim.lua` exrc is trusted.
      formatters_by_ft = {
        lua = { 'treefmt', 'stylua', stop_after_first = true },
        nix = { 'treefmt', 'nixfmt', stop_after_first = true },
        sh = { 'treefmt', 'shfmt', stop_after_first = true },
        bash = { 'treefmt', 'shfmt', stop_after_first = true },
        toml = { 'treefmt', 'taplo', stop_after_first = true },
        kdl = { 'kdlfmt' },
        yaml = { 'treefmt', 'yamlfmt', stop_after_first = true },
        json = { 'treefmt', 'oxfmt', stop_after_first = true },
        jsonc = { 'treefmt', 'oxfmt', stop_after_first = true },
        javascript = { 'oxfmt' },
        typescript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        markdown = { 'treefmt', 'mdformat', stop_after_first = true },
      },
      formatters = {
        -- The embedded language is formatted with its own formatter only, never
        -- with treefmt (that would run the whole tool-chain on the snippet).
        injected = {
          options = {
            lang_to_formatters = {
              sh = { 'shfmt' },
              bash = { 'shfmt' },
              markdown = { 'mdformat' },
              yaml = { 'yamlfmt' },
            },
          },
        },
        -- shfmt only reads the `.editorconfig` when the file it formats exists
        -- on disk. The temporary files that conform creates for injected code
        -- do not exist, so shfmt would fall back to its default (tabs). Pass
        -- the indent width explicitly in that case.
        shfmt = {
          args = function(_, ctx)
            local args = { '-filename', '$FILENAME' }
            local exists = vim.uv.fs_stat(ctx.filename) ~= nil
            if not exists and vim.bo[ctx.buf].expandtab then vim.list_extend(args, { '-i', ctx.shiftwidth }) end
            return args
          end,
        },
      },
    },
    before = function(plugin)
      if vim.g.auto_format == nil then vim.g.auto_format = true end
    end,
  },
}
