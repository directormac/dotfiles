-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- local function map(mode, l, r, desc)
-- 	vim.keymap.set(mode, l, r, { desc = desc })
-- end

-- Copy Paste Fixes
-- map("v", "p", "P", { noremap = true, silent = true, desc = "Paste content previously yanked" })
-- map("v", "P", "p", { noremap = true, silent = true, desc = "Yank what you are going to override, then paste" })

-- map({ "n", "v" }, "<C-x>", '"+y<esc>dd', { noremap = true, desc = "Copy and delete line" })
-- map({ "n", "v" }, "<C-y>", '"+yy<esc>', { noremap = true, desc = "Copy" })
-- map({ "n" }, "<C-p>", '"+p<esc>', { noremap = true, desc = "Paste" })
-- map("v", "x", '"_x', { noremap = true, silent = true, desc = "Delete character without yanking" })
-- map(
-- 	"n",
-- 	"x", -- Also let's allow 'x' key to delete blank lines in normal mode.
-- 	function()
-- 		if vim.fn.col(".") == 1 then
-- 			local line = vim.fn.getline(".")
-- 			if line:match("^%s*$") then
-- 				vim.api.nvim_feedkeys("dd", "n", false)
-- 				vim.api.nvim_feedkeys("$", "n", false)
-- 			else
-- 				vim.api.nvim_feedkeys('"_x', "n", false)
-- 			end
-- 		else
-- 			vim.api.nvim_feedkeys('"_x', "n", false)
-- 		end
-- 	end,
-- 	{ noremap = true, silent = true, desc = "Delete blank line without yanking" }
-- )
--
-- -- Blazingly fast way out of insert mode and terminal mode
-- map("i", "<C-c>", "<esc>")
-- -- map("t", "jj", "<C-\\><C-n>")
-- -- map("t", "jk", "<C-\\><C-n>")
--
-- map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Escape Insert Mode" })
--
-- -- Beter scrolllssssssss
-- map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
-- map("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })
--
-- -- Tabulation in visual mode
-- map("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
-- map("v", "<Tab>", ">gv", { desc = "Indent line" })o

local map = vim.keymap.set

-- Here is a utility function that closes any floating windows when you press escape
local function close_floating()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

map("n", "<leader>k", require("fzf-lua").keymaps, { desc = "Keymaps" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", function()
		Snacks.lazygit({ cwd = LazyVim.root.git() })
	end, { desc = "Lazygit (Root Dir)" })
	map("n", "<leader>gG", function()
		Snacks.lazygit()
	end, { desc = "Lazygit (cwd)" })
	map("n", "<leader>gf", function()
		Snacks.lazygit.log_file()
	end, { desc = "Lazygit Current File History" })
	map("n", "<leader>gl", function()
		Snacks.lazygit.log({ cwd = LazyVim.root.git() })
	end, { desc = "Lazygit Log" })
	map("n", "<leader>gL", function()
		Snacks.lazygit.log()
	end, { desc = "Lazygit Log (cwd)" })
end

map("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
	Snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git Browse (copy)" })
