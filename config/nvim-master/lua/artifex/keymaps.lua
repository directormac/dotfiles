-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Quit neovim
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit All' })
vim.keymap.set('n', '<leader>qf', '<cmd>noautocmd wqa!<CR>', { desc = 'Force write everything and Quit' })
vim.keymap.set('n', '<leader>qr', '<cmd>restart<CR>', { desc = 'Restart Neovim' })

-- Save without formatting on Ctrl+Shift+S (bypass autocommands)
vim.keymap.set({ 'n', 'i' }, '<C-S-s>', '<cmd>noautocmd w<CR><Esc>', { desc = 'Save File Without Formatting' })

-- Yank whole text
vim.keymap.set('n', '<leader>cy', ':%y+<CR>', { desc = 'Yank Entire Buffer' })

-- Select whole text
vim.keymap.set('n', '<leader>cs', 'ggVG', { desc = 'Select Entire Buffer' })

-- Lsp actions
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename Symbol' })

-- Function to copy all diagnostics to the clipboard
local function copy_all_diagnostics()
  local diagnostics = vim.diagnostic.get(nil) -- get all diagnostics in current buffer
  if vim.tbl_isempty(diagnostics) then
    vim.notify('No diagnostics to copy!', vim.log.levels.INFO)
    return
  end

  local lines = {}
  for _, d in ipairs(diagnostics) do
    local msg = string.format(
      '[%s] %s:%d:%d: %s',
      vim.diagnostic.severity[d.severity]:sub(1, 1),
      vim.api.nvim_buf_get_name(0),
      d.lnum + 1,
      d.col + 1,
      d.message:gsub('\n', ' ')
    )
    table.insert(lines, msg)
  end

  local text = table.concat(lines, '\n')
  vim.fn.setreg('+', text) -- copy to system clipboard
  vim.notify('Diagnostics copied to clipboard!', vim.log.levels.INFO)
end

-- Keymap: <leader>cd to copy all diagnostics
vim.keymap.set('n', '<leader>cd', copy_all_diagnostics, { desc = 'Copy All Diagnostics' })

-- Center screen after scrolling or searching (from prime)
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result centered' })

-- Navigate wrapped lines with arrow keys (gj/gk moves by visual line)
vim.keymap.set({ 'n', 'v' }, '<Down>', 'gj', { noremap = true, silent = true, desc = 'Move down by visual line' })
vim.keymap.set({ 'n', 'v' }, '<Up>', 'gk', { noremap = true, silent = true, desc = 'Move up by visual line' })

-- Map Ctrl-h and Ctrl-k to replicate default actions of Ctrl-o and Ctrl-i which are used by harpoon
vim.keymap.set('n', '<C-h>', '<C-o>', { desc = 'Jump back in jump list (same as Ctrl-o)' })
vim.keymap.set('n', '<C-k>', '<C-i>', { desc = 'Jump forward in jump list (same as Ctrl-i)' })

-- Map Ctrl-a to switch to the last buffer
vim.keymap.set('n', '<C-a>', '<C-^>', { desc = 'Switch to last buffer' })

-- Bind "(" for navigating to the previous error diagnostic using the new API
vim.keymap.set('n', '(', function()
  vim.diagnostic.jump({
    count = -1, -- Negative count moves to the previous diagnostic
  })
end, { desc = 'Go to previous error diagnostic' })

-- Bind ")" for navigating to the next error diagnostic using the new API
vim.keymap.set('n', ')', function()
  vim.diagnostic.jump({
    count = 1, -- Positive count moves to the next diagnostic
  })
end, { desc = 'Go to next error diagnostic' })

-- Navigation keymaps for next/previous functionality

-- Diagnostic Navigation
vim.keymap.set('n', '<leader>nd', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '<leader>pd', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous diagnostic' })

vim.keymap.set(
  'n',
  '<leader>ne',
  function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = 'Next error' }
)

vim.keymap.set(
  'n',
  '<leader>pe',
  function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = 'Previous error' }
)

vim.keymap.set(
  'n',
  '<leader>nw',
  function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = 'Next warning' }
)

vim.keymap.set(
  'n',
  '<leader>pw',
  function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = 'Previous warning' }
)

vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Resize window using <ctrl> arrow keys
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

vim.keymap.set('i', '<C-c>', '<esc>')
-- map("t", "jj", "<C-\\><C-n>")
-- map("t", "jk", "<C-\\><C-n>")

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, desc = 'Escape Insert Mode' })

-- Beter scrolllssssssss
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center cursor' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = ' up and center cursor' })

-- Tabulation in visual mode
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Unindent line' })
vim.keymap.set('v', '<Tab>', '>gv', { desc = 'Indent line' })

vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- save file
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

--keywordprg
vim.keymap.set('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- better indenting
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

-- commenting
vim.keymap.set('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
vim.keymap.set('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

-- highlights under cursor
vim.keymap.set('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
vim.keymap.set('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input('I')
end, { desc = 'Inspect Tree' })
