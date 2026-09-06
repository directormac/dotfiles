-- [[ Configure Treesitter ]]
--  Used to highlight, edit, and navigate code
--
--  See `:help nvim-treesitter-intro`

require('lazyload').on_vim_enter(function()
  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  })

  local H = {}

  H._installed = nil ---@type table<string,boolean>?
  H._queries = {} ---@type table<string,boolean>

  ---@param update boolean?
  function H.get_installed(update)
    if update then
      H._installed, H._queries = {}, {}
      for _, lang in ipairs(require('nvim-treesitter').get_installed('parsers')) do
        H._installed[lang] = true
      end
    end
    return H._installed or {}
  end

  function H.foldexpr() return H.have(nil, 'folds') and vim.treesitter.foldexpr() or '0' end

  function H.indentexpr() return H.have(nil, 'indents') and require('nvim-treesitter').indentexpr() or -1 end

  ---@return string?
  local function win_find_cl()
    local path = 'C:/Program Files (x86)/Microsoft Visual Studio'
    local pattern = '*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe'
    return vim.fn.globpath(path, pattern, true, true)[1]
  end

  ---@return boolean ok, lazyvim.util.treesitter.Health health
  function H.check()
    local is_win = vim.fn.has('win32') == 1
    ---@param tool string
    ---@param win boolean?
    local function have(tool, win) return (win == nil or is_win == win) and vim.fn.executable(tool) == 1 end

    local have_cc = vim.env.CC ~= nil or have('cc', false) or have('cl', true) or (is_win and win_find_cl() ~= nil)

    if not have_cc and is_win and vim.fn.executable('gcc') == 1 then
      vim.env.CC = 'gcc'
      have_cc = true
    end

    ---@class lazyvim.util.treesitter.Health: table<string,boolean>
    local ret = {
      ['tree-sitter (CLI)'] = have('tree-sitter'),
      ['C compiler'] = have_cc,
      tar = have('tar'),
      curl = have('curl'),
    }
    local ok = true
    for _, v in pairs(ret) do
      ok = ok and v
    end
    return ok, ret
  end

  ---@param cb fun()
  function H.build(cb)
    H.ensure_treesitter_cli(function(_, err)
      local ok, health = H.check()
      if ok then
        return cb()
      else
        local lines = { 'Unmet requirements for **nvim-treesitter** `main`:' }
        local keys = vim.tbl_keys(health) ---@type string[]
        table.sort(keys)
        for _, k in pairs(keys) do
          lines[#lines + 1] = ('- %s `%s`'):format(health[k] and '✅' or '❌', k)
        end
        vim.list_extend(lines, {
          '',
          'See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)',
          'Run `:checkhealth nvim-treesitter` for more information.',
        })
        if vim.fn.has('win32') == 1 and not health['C compiler'] then
          lines[#lines + 1] = 'Install a C compiler with `winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e`'
        end
        vim.list_extend(lines, err and { '', err } or {})
        Snacks.notify.error(lines, { title = 'LazyVim Treesitter' })
      end
    end)
  end

  ---@param cb fun(ok:boolean, err?:string)
  function H.ensure_treesitter_cli(cb)
    if vim.fn.executable('tree-sitter') == 1 then return cb(true) end

    -- try installing with mason
    if not pcall(require, 'mason') then
      return cb(false, '`mason.nvim` is disabled in your config, so we cannot install it automatically.')
    end

    -- check again since we might have installed it already
    if vim.fn.executable('tree-sitter') == 1 then return cb(true) end

    local mr = require('mason-registry')
    mr.refresh(function()
      local p = mr.get_package('tree-sitter-cli')
      if not p:is_installed() then
        Snacks.notify.info('Installing `tree-sitter-cli` with `mason.nvim`...')
        p:install(
          nil,
          vim.schedule_wrap(function(success)
            if success then
              Snacks.notify.info('Installed `tree-sitter-cli` with `mason.nvim`.')
              cb(true)
            else
              cb(false, 'Failed to install `tree-sitter-cli` with `mason.nvim`.')
            end
          end)
        )
      end
    end)
  end

  do
    local TS = require('nvim-treesitter')

    if not H.get_installed then
      Snacks.notify.warn('Treesitter not found, trying to install with mason. . . .')
      return
    end

    H.build(function() TS.update(nil, { summary = true }) end)
  end

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'bash',
    'c',
    'diff',
    'html',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'regex',
    'query',
    'vim',
    'vimdoc',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  }

  --- Run update when treesitter package is updated
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      if ev.data.spec.name == 'nvim-treesitter' then vim.cmd('TSUpdate') end
    end,
  })

  vim.api.nvim_create_autocmd('PackChanged', {
    desc = 'Handle nvim-treesitter updates',
    group = vim.api.nvim_create_augroup('nvim-treesitter-pack-changed-update-handler', { clear = true }),
    callback = function(event)
      if event.data.kind == 'update' then
        local ok = pcall(vim.cmd.TSUpdate)
        if ok then
          vim.notify('TSUpdate completed successfully!', vim.log.levels.INFO)
        else
          vim.notify('TSUpdate command not available yet, skipping', vim.log.levels.WARN)
        end
      end
    end,
  })

  local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()

  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed('parsers')

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { '*' },
    callback = function()
      local ft = vim.bo.filetype

      local ok = pcall(vim.treesitter.start)

      if not ok then return end

      -- Only when treesitter started. Must be per-buffer here: at module scope
      -- vim.bo/vim.wo only touch whatever buffer exists during startup.
      vim.wo[0].foldmethod = 'expr'
      vim.wo[0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.bo[0].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  -- -- Enable tree-sitter after opening a file for a target language
  -- local filetypes = {}
  -- for _, lang in ipairs(languages) do
  --   for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
  --     table.insert(filetypes, ft)
  --   end
  -- end
  -- local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  -- Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')

  vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter-context' })

  require('treesitter-context').setup({
    enable = true,
    multiwindow = false,
    max_lines = 0,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = 'outer',
    mode = 'cursor',
    separator = nil,
    zindex = 20,
    on_attach = nil,
  })
end)

-- return {
--
--   -- Treesitter is a new parser generator tool that we can
--   -- use in Neovim to power faster and more accurate
--   -- syntax highlighting.
--   {
--     "nvim-treesitter/nvim-treesitter",
--     branch = "main",
--     commit = vim.fn.has("nvim-0.12") == 0 and "7caec274fd19c12b55902a5b795100d21531391f" or nil,
--     version = false, -- last release is way too old and doesn't work on Windows
--     build = function()
--       local TS = require("nvim-treesitter")
--       if not TS.get_installed then
--         LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
--         return
--       end
--       -- make sure we're using the latest treesitter util
--       package.loaded["lazyvim.util.treesitter"] = nil
--       LazyVim.treesitter.build(function()
--         TS.update(nil, { summary = true })
--       end)
--     end,
--     event = { "LazyFile", "VeryLazy" },
--     cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
--     opts_extend = { "ensure_installed" },
--     ---@alias lazyvim.TSFeat { enable?: boolean, disable?: string[] }
--     ---@class lazyvim.TSConfig: TSConfig
--     opts = {
--       -- LazyVim config for treesitter
--       indent = { enable = true }, ---@type lazyvim.TSFeat
--       highlight = { enable = true }, ---@type lazyvim.TSFeat
--       folds = { enable = true }, ---@type lazyvim.TSFeat
--       ensure_installed = {
--         "bash",
--         "c",
--         "diff",
--         "html",
--         "javascript",
--         "jsdoc",
--         "json",
--         "lua",
--         "luadoc",
--         "luap",
--         "markdown",
--         "markdown_inline",
--         "printf",
--         "python",
--         "query",
--         "regex",
--         "toml",
--         "tsx",
--         "typescript",
--         "vim",
--         "vimdoc",
--         "xml",
--         "yaml",
--       },
--     },
--     ---@param opts lazyvim.TSConfig
--     config = function(_, opts)
--       local TS = require("nvim-treesitter")
--
--       setmetatable(require("nvim-treesitter.install"), {
--         __newindex = function(_, k)
--           if k == "compilers" then
--             vim.schedule(function()
--               LazyVim.error({
--                 "Setting custom compilers for `nvim-treesitter` is no longer supported.",
--                 "",
--                 "For more info, see:",
--                 "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
--               })
--             end)
--           end
--         end,
--       })
--
--       -- some quick sanity checks
--       if not TS.get_installed then
--         return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
--       elseif type(opts.ensure_installed) ~= "table" then
--         return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
--       end
--
--       -- setup treesitter
--       TS.setup(opts)
--       LazyVim.treesitter.get_installed(true) -- initialize the installed langs
--
--       -- install missing parsers
--       local install = vim.tbl_filter(function(lang)
--         return not LazyVim.treesitter.have(lang)
--       end, opts.ensure_installed or {})
--       if #install > 0 then
--         LazyVim.treesitter.build(function()
--           TS.install(install, { summary = true }):await(function()
--             LazyVim.treesitter.get_installed(true) -- refresh the installed langs
--           end)
--         end)
--       end
--
--       vim.api.nvim_create_autocmd("FileType", {
--         group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
--         callback = function(ev)
--           local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
--           if not LazyVim.treesitter.have(ft) then
--             return
--           end
--
--           ---@param feat string
--           ---@param query string
--           local function enabled(feat, query)
--             local f = opts[feat] or {} ---@type lazyvim.TSFeat
--             return f.enable ~= false
--               and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
--               and LazyVim.treesitter.have(ft, query)
--           end
--
--           -- highlighting
--           if enabled("highlight", "highlights") then
--             pcall(vim.treesitter.start, ev.buf)
--           end
--
--           -- indents
--           if enabled("indent", "indents") then
--             LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
--           end
--
--           -- folds
--           if enabled("folds", "folds") then
--             if LazyVim.set_default("foldmethod", "expr") then
--               LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
--             end
--           end
--         end,
--       })
--     end,
--   },
--
--   {
--     "nvim-treesitter/nvim-treesitter-textobjects",
--     branch = "main",
--     event = "VeryLazy",
--     opts = {
--       move = {
--         enable = true,
--         set_jumps = true, -- whether to set jumps in the jumplist
--         -- LazyVim extention to create buffer-local keymaps
--         keys = {
--           goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
--           goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
--           goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
--           goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
--         },
--       },
--     },
--     config = function(_, opts)
--       local TS = require("nvim-treesitter-textobjects")
--       if not TS.setup then
--         LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
--         return
--       end
--       TS.setup(opts)
--
--       local function attach(buf)
--         local ft = vim.bo[buf].filetype
--         if not (vim.tbl_get(opts, "move", "enable") and LazyVim.treesitter.have(ft, "textobjects")) then
--           return
--         end
--         ---@type table<string, table<string, string>>
--         local moves = vim.tbl_get(opts, "move", "keys") or {}
--
--         for method, keymaps in pairs(moves) do
--           for key, query in pairs(keymaps) do
--             local queries = type(query) == "table" and query or { query }
--             local parts = {}
--             for _, q in ipairs(queries) do
--               local part = q:gsub("@", ""):gsub("%..*", "")
--               part = part:sub(1, 1):upper() .. part:sub(2)
--               table.insert(parts, part)
--             end
--             local desc = table.concat(parts, " or ")
--             desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
--             desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
--             vim.keymap.set({ "n", "x", "o" }, key, function()
--               if vim.wo.diff and key:find("[cC]") then
--                 return vim.cmd("normal! " .. key)
--               end
--               require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
--             end, {
--               buffer = buf,
--               desc = desc,
--               silent = true,
--             })
--           end
--         end
--       end
--
--       vim.api.nvim_create_autocmd("FileType", {
--         group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
--         callback = function(ev)
--           attach(ev.buf)
--         end,
--       })
--       vim.tbl_map(attach, vim.api.nvim_list_bufs())
--     end,
--   },
--
--   -- Automatically add closing tags for HTML and JSX
--   {
--     "windwp/nvim-ts-autotag",
--     event = "LazyFile",
--     opts = {},
--   },
-- }

-- -- Custom parsers not shipped with nvim-treesitter.
-- local custom_parsers = {}
--
-- for lang, p in pairs(custom_parsers) do
--   vim.treesitter.language.register(lang, p.filetype)
-- end
--
-- local function inject_custom_parsers()
--   local parsers = require('nvim-treesitter.parsers')
--   for lang, p in pairs(custom_parsers) do
--     parsers[lang] = { install_info = p.install_info }
--   end
-- end
--
-- inject_custom_parsers()
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'TSUpdate',
--   callback = inject_custom_parsers,
-- })
--
-- require('lazyload').on_vim_enter(function()
--   require('treesitter-context').setup({
--     multiwindow = true,
--   })
-- end)
--
-- --- Sign parser .so on macOS to prevent code-signature crashes.
-- ---@param parser_name string
-- local function sign_parser_macos(parser_name)
--   if vim.fn.has('mac') ~= 1 then return end
--   local parser_path = vim.fn.stdpath('data') .. '/site/parser/' .. parser_name .. '.so'
--   if vim.fn.filereadable(parser_path) == 1 then vim.fn.system({ 'codesign', '--force', '--sign', '-', parser_path }) end
-- end
--
-- --- Install a parser via nvim-treesitter.
-- ---@param lang string parser/language name
-- ---@return boolean success
-- local function install_parser(lang)
--   if not Config.use_nvim_treesitter then return false end
--   local parsers = require('nvim-treesitter.parsers')
--   if not parsers[lang] then return false end
--   require('nvim-treesitter').install({ lang }):wait(30000)
--   sign_parser_macos(lang)
--   return true
-- end
--
-- --- Auto-start treesitter highlighting for every buffer.
-- --- Registered at plugin/ sourcing time (step 11) so it runs before LSP's
-- --- FileType handlers (registered at VimEnter), preventing race conditions
-- --- with plugins that use treesitter queries on LspAttach.
-- vim.api.nvim_create_autocmd('FileType', {
--   group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
--   callback = function(event)
--     local bufnr = event.buf
--     local ft = event.match
--     if ft == '' then return end
--
--     local lang = vim.treesitter.language.get_lang(ft)
--     if not lang then return end
--
--     local ok = pcall(vim.treesitter.start, bufnr, lang)
--     if ok then return end
--
--     if install_parser(lang) then pcall(vim.treesitter.start, bufnr, lang) end
--   end,
-- })
