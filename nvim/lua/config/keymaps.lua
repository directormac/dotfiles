local Util = require("helpers.util")
local map = require("helpers.util").map

-- Copy Paste Fixes
map("v", "p", "P", { noremap = true, silent = true })
map({ "n", "v" }, "<leader>y", '"+y', { noremap = true, desc = "Copy to OSC52 Clipboard" })
map({ "n", "v" }, "<leader>yy", '"+yy', { noremap = true, desc = "Copy to OSC52 Clipboard" })

-- Blazingly fast way out of insert mode and terminal mode
map("i", "jj", "<esc>")
map("i", "jk", "<esc>")
map("i", "<C-c>", "<esc>")
map("t", "jj", "<C-\\><C-n>")
map("t", "jk", "<C-\\><C-n>")
map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Escape Insert Mode" })

-- Beter scrolllssssssss
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })
map("n", "-", require("oil").open, { desc = "Open Oil File Explorer" })

-- Popup windows , aerial, oil toggles
map("n", "<Leader>e", function()
  local cwd = require("oil").get_current_dir()
  require("oil").toggle_float(cwd)
end, { desc = "Opel Oil Floating" })
map("n", "<leader>o", "<cmd>AerialToggle!<CR>")

--Popup Helpers
map("n", "<F1>", "<cmd>Telescope keymaps<cr>", { noremap = true, desc = "Key Maps" })
map("n", "<F2>", "<cmd>Telescope help_tags<cr>", { noremap = true, desc = "Help Pages" })
map("n", "<F3>", "<cmd>Telescope man_pages<cr>", { noremap = true, desc = "Manual Pages" })
map("n", "<F4>", "<cmd>Telescope diagnostics<cr>", { noremap = true, desc = "Workspace Diagnostics" })

-- Browse Files
map(
  "n",
  "<leader>fb",
  ":Telescope file_browser file_browser winblend=10 previewer=false theme=dropdown path=%:p:h=%:p:h<cr>",
  { desc = "Browse Files", noremap = true }
)
map(
  "n",
  "<leader>fB",
  ":Telescope file_browser file_browser winblend=10 previewer=true path=%:p:h=%:p:h<cr>",
  { desc = "Browse Files with Preview", noremap = true }
)
-- Recent files
map(
  "n",
  "<leader>fr",
  Util.telescope("oldfiles", { cwd = vim.loop.cwd(), winblend = 10, previewer = false }),
  { desc = "Recently opened" }
)
map(
  "n",
  "<leader>fR",
  Util.telescope("oldfiles", { cwd = vim.loop.cwd(), winblend = 10 }),
  { desc = "Recently opened" }
)

-- Buffers
map("n", "<leader><space>", "<cmd>Telescope buffers show_all_buffers=true<cr>", { desc = "Open buffers" })

-- Current Buffer finder

map("n", "<leader>.", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "Search in current buffer" })

-- Live Grep
map("n", "<leader>/", Util.telescope("live_grep"), { desc = "Grep (root dir) " })
map("n", "<leader>fg", Util.telescope("live_grep"), { desc = "Grep (root dir)" })
map("n", "<leader>fG", Util.telescope("live_grep", { cwd = false }), { desc = "Grep (cwd)" })
map("n", "<leader>fw", Util.telescope("grep_string"), { desc = "Word (root dir)" })
map("n", "<leader>fW", Util.telescope("grep_string", { cwd = false }), { desc = "Word (cwd)" })

-- Files
map("n", "<leader>ff", Util.telescope("files"), { desc = "Find Files (root dir)" })
map("n", "<leader>fF", Util.telescope("files", { cwd = false }), { desc = "Find Files (cwd)" })
map("n", "<leader>fs", "<cmd>Telescope scope buffers<cr>", { desc = "Sessions" })

-- Blazing Greps
map("n", "<leader>sg", Util.telescope("live_grep"), { desc = "Grep (root dir)" })
map("n", "<leader>sG", Util.telescope("live_grep", { cwd = false }), { desc = "Grep (cwd)" })
map("n", "<leader>sw", Util.telescope("grep_string"), { desc = "Word (root dir)" })
map("n", "<leader>sW", Util.telescope("grep_string", { cwd = false }), { desc = "Word (cwd)" })
map("n", "<leader>sa", "<cmd>Telescope autocommands<cr>", { desc = "Auto Commands" })
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer" })
map("n", "<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command History" })
map("n", "<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })
map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" })
map("n", "<leader>sH", "<cmd>Telescope highlights<cr>", { desc = "Search Highlight Groups" })
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
map("n", "<leader>sM", "<cmd>Telescope man_pages<cr>", { desc = "Man Pages" })
map("n", "<leader>sm", "<cmd>Telescope marks<cr>", { desc = "Jump to Mark" })
map("n", "<leader>so", "<cmd>Telescope vim_options<cr>", { desc = "Options" })
map("n", "<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Resume" })
map(
  "n",
  "<leader>ss",
  Util.telescope("lsp_document_symbols", {
    symbols = {
      "Class",
      "Function",
      "Method",
      "Constructor",
      "Interface",
      "Module",
      "Struct",
      "Trait",
      "Field",
      "Property",
    },
  }),
  { desc = "Goto Symbol" }
)
map(
  "n",
  "<leader>sS",
  Util.telescope("lsp_dynamic_workspace_symbols", {
    symbols = {
      "Class",
      "Function",
      "Method",
      "Constructor",
      "Interface",
      "Module",
      "Struct",
      "Trait",
      "Field",
      "Property",
    },
  }),
  { desc = "Goto Symbol (Workspace)" }
)

-- git
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "status" })
-- lazygit
map("n", "<leader>gg", function()
  Util.float_term({ "lazygit" }, { cwd = Util.get_root(), esc_esc = false })
end, { desc = "Lazygit (root dir)" })
map("n", "<leader>gG", function()
  Util.float_term({ "lazygit" }, { esc_esc = false })
end, { desc = "Lazygit (cwd)" })

-- Find help
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })
map("n", "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command History" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })
-- map("n", "<C-p>", require("telescope.builtin").keymaps, { desc = "Search keymaps" })
local keys = {
  { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
  { "<leader>/", Util.telescope("live_grep"), desc = "Grep (root dir)" },
  { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
  { "<leader><space>", Util.telescope("files"), desc = "Find Files (root dir)" },
}
-- Save files with Ctrl-s
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })
-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

if not Util.has("trouble.nvim") then
  map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
  map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
end

-- stylua: ignore start
--
map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>ul", function()
  Util.toggle("relativenumber", true)
  Util.toggle("number")
end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ud", Util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() Util.toggle("conceallevel", false, { 0, conceallevel }) end,
  { desc = "Toggle Conceal" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- floating terminal
local lazyterm = function() Util.float_term(nil, { cwd = Util.get_root() }) end
map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>fT", function() Util.float_term() end, { desc = "Terminal (cwd)" })
map("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<c-_>", lazyterm, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- buffers
if Util.has("bufferline.nvim") then
  map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })



map("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Show Mason" })

-- local lsp_map = require("helpers.keys").lsp_map
--
-- lsp_map("<leader>lr", vim.lsp.buf.rename, bufnr, { desc = "Rename symbol" })
-- lsp_map("<leader>la", vim.lsp.buf.code_action, bufnr, { desc = "Code action" })
-- lsp_map("<leader>ld", vim.lsp.buf.type_definition, bufnr, { desc = "Type definition" })
-- lsp_map(
--   "<leader>ls",
--   require("telescope.builtin").lsp_document_symbols,
--   bufnr,
--   { desc = "Document symbols" }
-- )
-- lsp_map("gd", vim.lsp.buf.definition, bufnr, { desc = "Goto Definition" })
-- lsp_map("gr", require("telescope.builtin").lsp_references, bufnr, { desc = "Goto References" })
-- lsp_map("gI", vim.lsp.buf.implementation, bufnr, { desc = "Goto Implementation" })
-- lsp_map("K", vim.lsp.buf.hover, bufnr, { desc = "Hover Documentation" })
-- lsp_map("gD", vim.lsp.buf.declaration, bufnr, { desc = "Goto Declaration" })
-- lsp_map("<leader>cf", "<cmd>Format<cr>", bufnr, { desc = "Format" })
--
