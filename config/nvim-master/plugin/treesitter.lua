require('lazyload').on_vim_enter(function()
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      if ev.data.spec.name == 'nvim-treesitter' then vim.cmd('TSUpdate') end
    end,
  })

  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  })

  -- Custom parsers not shipped with nvim-treesitter.
  local custom_parsers = {}

  for lang, p in pairs(custom_parsers) do
    vim.treesitter.language.register(lang, p.filetype)
  end

  local function inject_custom_parsers()
    local parsers = require('nvim-treesitter.parsers')
    for lang, p in pairs(custom_parsers) do
      parsers[lang] = { install_info = p.install_info }
    end
  end

  inject_custom_parsers()

  vim.api.nvim_create_autocmd('User', {
    pattern = 'TSUpdate',
    callback = inject_custom_parsers,
  })

  require('lazyload').on_vim_enter(
    function()
      require('treesitter-context').setup({
        multiwindow = true,
      })
    end
  )

  --- Sign parser .so on macOS to prevent code-signature crashes.
  ---@param parser_name string
  local function sign_parser_macos(parser_name)
    if vim.fn.has('mac') ~= 1 then return end
    local parser_path = vim.fn.stdpath('data') .. '/site/parser/' .. parser_name .. '.so'
    if vim.fn.filereadable(parser_path) == 1 then
      vim.fn.system({ 'codesign', '--force', '--sign', '-', parser_path })
    end
  end

  --- Install a parser via nvim-treesitter.
  ---@param lang string parser/language name
  ---@return boolean success
  local function install_parser(lang)
    if not Config.use_nvim_treesitter then return false end
    local parsers = require('nvim-treesitter.parsers')
    if not parsers[lang] then return false end
    require('nvim-treesitter').install({ lang }):wait(30000)
    sign_parser_macos(lang)
    return true
  end

  --- Auto-start treesitter highlighting for every buffer.
  --- Registered at plugin/ sourcing time (step 11) so it runs before LSP's
  --- FileType handlers (registered at VimEnter), preventing race conditions
  --- with plugins that use treesitter queries on LspAttach.
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
    callback = function(event)
      local bufnr = event.buf
      local ft = event.match
      if ft == '' then return end

      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then return end

      local ok = pcall(vim.treesitter.start, bufnr, lang)
      if ok then return end

      if install_parser(lang) then pcall(vim.treesitter.start, bufnr, lang) end
    end,
  })
end)

-- -- [[ Configure Treesitter ]]
-- --  Used to highlight, edit, and navigate code
-- --
-- --  See `:help nvim-treesitter-intro`
--
-- -- NOTE: You can also specify a branch or a specific commit
-- vim.pack.add({
--   'https://github.com/nvim-treesitter/nvim-treesitter',
--   'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
-- })
--
-- -- Define languages which will have parsers installed and auto enabled
-- -- After changing this, restart Neovim once to install necessary parsers. Wait
-- -- for the installation to finish before opening a file for added language(s).
-- local languages = {
--   -- These are already pre-installed with Neovim. Used as an example.
--   'bash',
--   'c',
--   'diff',
--   'html',
--   'lua',
--   'luadoc',
--   'markdown',
--   'markdown_inline',
--   'regex',
--   'query',
--   'vim',
--   'vimdoc',
--   -- Add here more languages with which you want to use tree-sitter
--   -- To see available languages:
--   -- - Execute `:=require('nvim-treesitter').get_available()`
--   -- - Visit 'SUPPORTED_LANGUAGES.md' file at
--   --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
-- }
-- local isnt_installed = function(lang)
--   return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
-- end
-- local to_install = vim.tbl_filter(isnt_installed, languages)
-- if #to_install > 0 then require('nvim-treesitter').install(to_install) end
--
-- ---@param buf integer
-- ---@param language string
-- local function treesitter_try_attach(buf, language)
--   -- Check if a parser exists and load it
--   if not vim.treesitter.language.add(language) then return end
--   -- Enable syntax highlighting and other treesitter features
--   vim.treesitter.start(buf, language)
--
--   -- Enable treesitter based folds
--   -- For more info on folds see `:help folds`
--   -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
--   -- vim.wo.foldmethod = 'expr'
--
--   -- Check if treesitter indentation is available for this language, and if so enable it
--   -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
--   local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
--
--   -- Enable treesitter based indentation
--   if has_indent_query then
--     vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
--   end
-- end
--
-- local available_parsers = require('nvim-treesitter').get_available()
-- vim.api.nvim_create_autocmd('FileType', {
--   callback = function(args)
--     local buf, filetype = args.buf, args.match
--
--     local language = vim.treesitter.language.get_lang(filetype)
--     if not language then return end
--
--     local installed_parsers =
--       require('nvim-treesitter').get_installed('parsers')
--
--     if vim.tbl_contains(installed_parsers, language) then
--       -- Enable the parser if it is already installed
--       treesitter_try_attach(buf, language)
--     elseif vim.tbl_contains(available_parsers, language) then
--       -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
--       require('nvim-treesitter')
--         .install(language)
--         :await(function() treesitter_try_attach(buf, language) end)
--     else
--       -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
--       treesitter_try_attach(buf, language)
--     end
--   end,
-- })
--
--
-- vim.api.nvim_create_autocmd("PackChanged", {
-- 	desc = "Handle nvim-treesitter updates",
-- 	group = vim.api.nvim_create_augroup("nvim-treesitter-pack-changed-update-handler", { clear = true }),
-- 	callback = function(event)
-- 		if event.data.kind == "update" then
-- 			local ok = pcall(vim.cmd.TSUpdate)
-- 			if ok then
-- 				vim.notify("TSUpdate completed successfully!", vim.log.levels.INFO)
-- 			else
-- 				vim.notify("TSUpdate command not available yet, skipping", vim.log.levels.WARN)
-- 			end
-- 		end
-- 	end,
-- })
--
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "*" },
-- 	callback = function()
-- 		local ft = vim.bo.filetype
--
-- 		local ok = pcall(vim.treesitter.start)
--
-- 		if not ok then
-- 			return
-- 		end
--
-- 		-- Only when treesitter started. Must be per-buffer here: at module scope
-- 		-- vim.bo/vim.wo only touch whatever buffer exists during startup.
-- 		vim.wo[0].foldmethod = "expr"
-- 		vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 		vim.bo[0].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
-- 	end,
-- })
--
--
--
--
--
-- -- -- Enable tree-sitter after opening a file for a target language
-- -- local filetypes = {}
-- -- for _, lang in ipairs(languages) do
-- --   for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
-- --     table.insert(filetypes, ft)
-- --   end
-- -- end
-- -- local ts_start = function(ev) vim.treesitter.start(ev.buf) end
-- -- Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
--
-- vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter-context' })
--
-- require('treesitter-context').setup({
--   enable = true,
--   multiwindow = false,
--   max_lines = 0,
--   min_window_height = 0,
--   line_numbers = true,
--   multiline_threshold = 20,
--   trim_scope = 'outer',
--   mode = 'cursor',
--   separator = nil,
--   zindex = 20,
--   on_attach = nil,
-- })
