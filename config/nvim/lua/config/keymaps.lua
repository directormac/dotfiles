-- Global keymaps.
-- See `:help vim.keymap.set()`

-- Keymaps for better default experience
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll Down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll Up' })

-- Buffer navigation (Lualine & Neovim)
vim.keymap.set('n', '<S-h>', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '[b', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '[B', '<cmd>bfirst<CR>', { desc = 'First buffer' })
vim.keymap.set('n', ']B', '<cmd>blast<CR>', { desc = 'Last buffer' })

-- Jump directly to buffer by index using Lualine
vim.keymap.set('n', '<A-1>', '<cmd>LualineBuffersJump! 1<CR>', { desc = 'Go to buffer 1' })
vim.keymap.set('n', '<A-2>', '<cmd>LualineBuffersJump! 2<CR>', { desc = 'Go to buffer 2' })
vim.keymap.set('n', '<A-3>', '<cmd>LualineBuffersJump! 3<CR>', { desc = 'Go to buffer 3' })
vim.keymap.set('n', '<A-4>', '<cmd>LualineBuffersJump! 4<CR>', { desc = 'Go to buffer 4' })
vim.keymap.set('n', '<A-5>', '<cmd>LualineBuffersJump! 5<CR>', { desc = 'Go to buffer 5' })
vim.keymap.set('n', '<A-6>', '<cmd>LualineBuffersJump! 6<CR>', { desc = 'Go to buffer 6' })

-- Buffer actions
local function buf_delete(buf) require('config.util').buf_delete(buf) end

vim.keymap.set('n', '<leader>bd', function() buf_delete() end, { desc = 'Delete buffer' })

vim.keymap.set('n', '<leader>bo', function()
  if package.loaded['snacks'] and Snacks.bufdelete and Snacks.bufdelete.other then
    Snacks.bufdelete.other()
  else
    vim.cmd('%bd|e#|bd#')
  end
end, { desc = 'Delete other buffers' })

-- Close buffers to the right
vim.keymap.set('n', '<leader>br', function()
  local current = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local found = false
  for _, b in ipairs(bufs) do
    if found then
      buf_delete(b.bufnr)
    elseif b.bufnr == current then
      found = true
    end
  end
end, { desc = 'Delete buffers to the right' })

-- Close buffers to the left
vim.keymap.set('n', '<leader>bl', function()
  local current = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  for _, b in ipairs(bufs) do
    if b.bufnr == current then break end
    buf_delete(b.bufnr)
  end
end, { desc = 'Delete buffers to the left' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>xl', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set({ 'v', 'x', 'n' }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set(
  { 'n', 'v', 'x' },
  '<leader>Y',
  '"+yy',
  { noremap = true, silent = true, desc = 'Yank line to clipboard' }
)
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set(
  'i',
  '<C-p>',
  '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' }
)
vim.keymap.set(
  'x',
  '<leader>P',
  '"_dP',
  { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' }
)

-- Quit neovim
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit All' })
vim.keymap.set('n', '<leader>qf', '<cmd>noautocmd wqa!<CR>', { desc = 'Force write everything and Quit' })
vim.keymap.set('n', '<leader>qr', '<cmd>restart<CR>', { desc = 'Restart Neovim' })

vim.keymap.set(
  'n',
  '<leader>sp',
  '<cmd>lua nixInfo.lze.debug.display(nixInfo.plugins)<CR>',
  { desc = 'Show Lazy Plugins' }
)

-- Keybinds to make split navigation easier.
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

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, desc = 'Escape Insert Mode' })

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

-- Save without formatting on Ctrl+Shift+S (bypass autocommands)
vim.keymap.set({ 'n', 'i' }, '<C-S-s>', '<cmd>noautocmd w<CR><Esc>', { desc = 'Save File Without Formatting' })

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

vim.keymap.set({ 'i', 'n', 's' }, '<esc>', function()
  vim.cmd('noh')
  if vim.snippet then vim.snippet.stop() end
  return '<esc>'
end, { expr = true, desc = 'Escape and clear hlsearch/snippet' })

vim.keymap.set('n', '<leader>uf', function()
  vim.g.auto_format = not vim.g.auto_format
  vim.notify('Auto-format: ' .. (vim.g.auto_format and 'on' or 'off'))
end, { desc = 'Toggle auto-format' })

-- Yank/Select whole text
vim.keymap.set('n', '<leader>cy', ':%y+<CR>', { desc = 'Yank Entire Buffer' })
vim.keymap.set('n', '<leader>cs', 'ggVG', { desc = 'Select Entire Buffer' })

-- Navigate wrapped lines with arrow keys (matches your j/k setup)
vim.keymap.set({ 'n', 'v' }, '<Down>', 'gj', { noremap = true, silent = true, desc = 'Move down by visual line' })
vim.keymap.set({ 'n', 'v' }, '<Up>', 'gk', { noremap = true, silent = true, desc = 'Move up by visual line' })
