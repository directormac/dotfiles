vim.lsp.config('tmux_ls', {
  cmd = { 'tmux-language-server' },
  filetypes = { 'tmux' },
  root_markers = { '.git', '.tmux.conf', 'tmux.conf' },
})

---@type vim.lsp.Config
vim.lsp.config('nil_ls', {
  ---@type lspconfig.settings.nil_ls
  settings = {
    formatting = {
      command = { 'treefmt' },
    },
  },
})

---@type vim.lsp.Config
vim.lsp.config('nixd', {
  ---@type lspconfig.settings.nixd
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }',
      },
      formatting = {
        command = { 'treefmt' },
      },
      options = {
        nixos = {
          expr = '(let flake = builtins.getFlake (toString ./.); pkgs = import flake.inputs.nixpkgs { }; in (pkgs.lib.evalModules { modules = (import "${flake.inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options',
        },
        home_manager = {
          expr = '(let flake = builtins.getFlake (toString ./.); pkgs = import flake.inputs.nixpkgs { }; lib = import "${flake.inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib; in (lib.evalModules { modules = (import "${flake.inputs.home-manager}/modules/modules.nix") { inherit lib pkgs; check = false; }; })).options',
        },
      },
    },
  },
})

vim.lsp.enable('tmux_ls')

vim.filetype.add({
  pattern = {
    ['.*tmux%.conf'] = 'tmux',
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- Example keymaps for navigation/inspection
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded', silent = true }) end, opts)

    -- Enable built-in completion if supported
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- vim.treesitter.language.add('python', { path = "" })
-- The `tmux` filetype is mapped to the `tmux` grammar (the tree-sitter parser
-- is provided by the tmux aspect). `conf` is deliberately not mapped: other
-- `*.conf` files are not tmux configuration.
vim.treesitter.language.register('tmux', { 'tmux' })

-- Read more here https://swarsel.github.io/pedantix/configuration.html
-- or type `:h exrc`

-- NOTE: this file is sourced through 'exrc' (see `vim.o.exrc` in
-- `config/nvim/lua/options.lua`) when Neovim is started inside this
-- repository, i.e. *before* the plugins are loaded. The configuration below
-- is therefore the one that is in effect here; the global defaults live in
-- `config/nvim/lua/plugins/conform.lua`.
--
-- `conform.setup()` must NOT be called from this file. Every call re-creates
-- the "Conform" augroup with `clear = true`, which deletes the `BufWritePre`
-- autocmd that the global `setup()` registered for format-on-save. A second
-- `setup()` that does not repeat the `format_on_save` option therefore
-- silently disables format-on-save for the whole session.
--
-- The global configuration is already in place at this point: `require` pulls
-- the plugin in, which runs its `opts` and therefore its `setup()` call. The
-- tables below are merged into the existing ones instead of calling
-- `setup()` again, so that the global `format_on_save` (and its autocmd)
-- stays registered.

local conform = require('conform')

conform.formatters_by_ft = vim.tbl_extend('force', conform.formatters_by_ft, {
  nix = { 'treefmt', 'nixfmt', stop_after_first = true },
  lua = { 'treefmt', 'stylua', stop_after_first = true },
  toml = { 'treefmt', 'taplo', stop_after_first = true },
  markdown = { 'treefmt', 'mdformat', stop_after_first = true },
  yaml = { 'treefmt', 'yamlfmt', stop_after_first = true },
  sh = { 'treefmt', 'shfmt', stop_after_first = true },
  bash = { 'treefmt', 'shfmt', stop_after_first = true },
  json = { 'treefmt', 'oxfmt', stop_after_first = true },
  jsonc = { 'treefmt', 'oxfmt', stop_after_first = true },
})

conform.formatters = vim.tbl_deep_extend('force', conform.formatters, {
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
})

vim.lsp.enable({
  'lua_ls',
  'nixd',
  'taplo',
  'nil_ls',
  'bashls',
  'yamlls',
  'marksman',
  'jsonls',
  'tmux_ls',
})

-- Language aliases.
--
-- `sh` is a *filetype*, not a tree-sitter parser name. The Nix injection
-- convention (`# sh` above a `''` string) injects the language written in the
-- comment, and Neovim resolves that name through the filetype mapping.
-- Mapping `sh` -> `bash` therefore makes `# sh` injections resolve to the bash
-- grammar (with its queries), and it also gives `.sh`/`.envrc` files proper
-- highlighting instead of silently finding no parser at all.
vim.treesitter.language.register('bash', { 'sh' })

-- Disable the nested `bash` injection of the tmux grammar.
--
-- The tmux grammar ships an `injections` query that injects `bash` into every
-- `(shell)` node it parses. Inside a Nix file the tmux configuration is
-- itself injected, so the parsers nest bash -> tmux -> nix and every
-- `run-shell "..."` style command spawns another bash parser.
--
-- That makes parsing the embedded configuration about seven times slower
-- (30ms instead of 4ms per parse), which shows up as slow scrolling and slow
-- redraws while editing a Nix file that embeds a tmux configuration. The
-- nested injection only adds highlighting inside shell commands, which is not
-- worth the lag, so it is turned off. The tmux highlighting itself is
-- unaffected: only the `injections` query is replaced.
vim.treesitter.query.set(
  'tmux',
  'injections',
  '; The nested `bash` injection of the tmux grammar is disabled, see the comment above.\n'
)

-- Custom predicate for TOML query injections (mise task scripts)
vim.treesitter.query.add_predicate('is-mise?', function(_, _, bufnr, _)
  local b = tonumber(bufnr) or 0
  if b == 0 then b = vim.api.nvim_get_current_buf() end

  if vim.b[b] and vim.b[b]._mise_checked ~= nil then return vim.b[b]._is_mise_file end

  local filepath = vim.api.nvim_buf_get_name(b)
  if filepath == '' then
    if vim.b[b] then
      vim.b[b]._is_mise_file = false
      vim.b[b]._mise_checked = true
    end
    return false
  end

  local filename = vim.fs.basename(filepath)
  local is_mise = false

  if string.match(filename, '.*mise.*%.toml$') then
    is_mise = true
  elseif filename == 'tasks.toml' then
    local dir = vim.fs.dirname(filepath)
    local found = vim.fs.find({ 'mise.toml', '.mise.toml' }, {
      path = dir,
      upward = true,
      type = 'file',
    })
    is_mise = #found > 0
  end

  if vim.b[b] then
    vim.b[b]._is_mise_file = is_mise
    vim.b[b]._mise_checked = true
  end
  return is_mise
end, { force = true, all = false })

-- -- render-markdown: renders markdown buffers and markdown that is embedded in
-- -- other documents.
-- --
-- -- The markdown of a Nix file lives inside an indented string (`'' ... ''`), so
-- -- it is indented as well - and the Nix formatter (nixfmt) keeps it that way.
-- -- The markdown parser treats content that is indented by four spaces or more
-- -- as an indented code block, so the embedded markdown would never be parsed
-- -- as markdown.
-- --
-- -- To render it nevertheless, the embedded markdown is dedented, rendered in a
-- -- scratch buffer (render-markdown renders it there) and the resulting marks
-- -- are copied back into the Nix buffer.
--
-- local NAMESPACE = 'nix-markdown'
-- local render_namespace = 'render-markdown.nvim'
-- local namespace_id = vim.api.nvim_create_namespace(NAMESPACE)
--
-- ---Remove the common indentation of the given lines.
-- ---@param lines string[]
-- ---@return string[] dedented, integer indent
-- local function dedent(lines)
--   local indent
--   for _, line in ipairs(lines) do
--     if line:match('%S') then
--       local width = #(line:match('^ *'))
--       if not indent or width < indent then indent = width end
--     end
--   end
--   indent = indent or 0
--
--   local dedented = {}
--   for _, line in ipairs(lines) do
--     dedented[#dedented + 1] = line:sub(indent + 1)
--   end
--   return dedented, indent
-- end
--
-- ---The regions of the buffer that are injected as markdown.
-- ---@param bufnr integer
-- ---@return table[] list of { start_row, start_col, end_row, end_col }
-- local function markdown_regions(bufnr)
--   local filetype = vim.bo[bufnr].filetype
--   local language = vim.treesitter.language.get_lang(filetype)
--   if not language then return {} end
--   if not vim.treesitter.query.get(language, 'injections') then return {} end
--
--   local ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
--   if not ok or not parser then return {} end
--   parser:parse(true)
--
--   local regions = {}
--   for _, tree in pairs(parser:children()) do
--     if tree:lang() == 'markdown' then
--       for _, ranges in ipairs(tree:included_regions()) do
--         for _, region in ipairs(ranges) do
--           regions[#regions + 1] = region
--         end
--       end
--     end
--   end
--   return regions
-- end
--
-- ---Render the markdown of the given region in a scratch buffer and copy the
-- ---resulting marks back into the buffer.
-- ---@param bufnr integer
-- ---@param region integer[]
-- local function render_region(bufnr, region)
--   -- the range is { start_row, start_col, start_byte, end_row, end_col, end_byte }
--   local start_row, start_col = region[1], region[2]
--   local end_row, end_col = region[4], region[5]
--
--   local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
--   if #lines == 0 then return end
--   -- the last line of the region can be cut off
--   lines[#lines] = lines[#lines]:sub(1, end_col)
--   -- the region starts in the middle of the first line
--   if start_col > 0 then lines[1] = lines[1]:sub(start_col + 1) end
--
--   local dedented, indent = dedent(lines)
--
--   local scratch = vim.api.nvim_create_buf(false, true)
--   local win
--   local ok = pcall(function()
--     vim.api.nvim_buf_set_lines(scratch, 0, -1, false, dedented)
--     -- the window has to exist before the filetype is set: render-markdown
--     -- renders the buffer when it is attached (on the FileType event).
--     win = vim.api.nvim_open_win(scratch, false, {
--       relative = 'editor',
--       row = 0,
--       col = 0,
--       width = 1,
--       height = 1,
--       style = 'minimal',
--       hide = true,
--       focusable = false,
--     })
--     vim.bo[scratch].filetype = 'markdown'
--     -- render the scratch buffer synchronously (the regular render is
--     -- debounced and therefore asynchronous)
--     require('render-markdown.core.ui').updater.new(scratch, win, true):run()
--   end)
--   if not ok then
--     pcall(vim.api.nvim_buf_delete, scratch, { force = true })
--     return
--   end
--
--   local source_namespace = vim.api.nvim_get_namespaces()[render_namespace]
--   if source_namespace then
--     for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(scratch, source_namespace, 0, -1, { details = true })) do
--       local row = mark[2] + start_row
--       local col = mark[3] + indent
--       -- the details of an extmark contain the namespace (and the id), which
--       -- are not valid options for `nvim_buf_set_extmark`
--       local opts = vim.deepcopy(mark[4])
--       opts.ns_id = nil
--       opts.id = nil
--       pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace_id, row, col, opts)
--     end
--   end
--
--   if win and vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, { force = true }) end
--   pcall(vim.api.nvim_buf_delete, scratch, { force = true })
--   -- render-markdown keeps a list of the buffers it renders, the scratch
--   -- buffer must not stay in it (buffer numbers are reused).
--   pcall(function()
--     local manager = require('render-markdown.core.manager')
--     for index, buffer in ipairs(manager.buffers) do
--       if buffer == scratch then
--         table.remove(manager.buffers, index)
--         break
--       end
--     end
--   end)
-- end
--
-- ---Render all markdown that is embedded in the buffer.
-- ---@param bufnr integer
-- local function render_embedded_markdown(bufnr)
--   if not vim.api.nvim_buf_is_valid(bufnr) then return end
--   vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
--
--   for _, region in ipairs(markdown_regions(bufnr)) do
--     render_region(bufnr, region)
--   end
-- end
--
-- return {
--   {
--     'render-markdown.nvim',
--     -- `nix` is included because Nix files embed markdown (the `# markdown`
--     -- injection convention used by `modules/flake-parts/files/*.nix`).
--     ft = { 'markdown', 'codecompanion', 'nix' },
--     cmd = { 'RenderMarkdown' },
--     opts = {
--       file_types = { 'markdown', 'codecompanion', 'nix' },
--       completions = { lsp = { enabled = true } },
--       code = {
--         render_modes = true,
--         conceal_delimiters = false,
--         border = 'thick',
--       },
--     },
--     after = function()
--       -- The markdown that is embedded in a Nix file is rendered separately (see
--       -- the comment at the top of this file).
--       local group = vim.api.nvim_create_augroup('NixMarkdown', { clear = true })
--       local rendered = {}
--
--       local function update(bufnr)
--         if vim.bo[bufnr].filetype ~= 'nix' then return end
--         -- only re-render when the content changed
--         local tick = vim.b[bufnr].changedtick
--         if rendered[bufnr] == tick then return end
--         rendered[bufnr] = tick
--         render_embedded_markdown(bufnr)
--       end
--
--       vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufWinEnter', 'InsertLeave' }, {
--         group = group,
--         callback = function(args) update(args.buf) end,
--       })
--     end,
--   },
-- }
