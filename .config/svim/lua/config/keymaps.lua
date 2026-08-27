local map = vim.keymap.set

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

--
--   Error  08:45:12 AM msg_show.echoerr LSP[lua_ls]:
-- Error ON_ATTACH_ERROR: '[string "vim/keymap"]:60: rhs: expected string|function, got nil'
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })

map("n", "<leader>cf", function()
  require("conform").format({
    lsp_format = "fallback",
  })
end, { desc = "Format current file" })

-- Map <leader>fp to open projects
map("n", "<leader>fp", ":ProjectFzf<CR>", { noremap = true, silent = true })

-- map({ "n", "v" }, "<C-y>", '"+yy<esc>', { desc = "Copy" })

map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map({ "n", "v" }, "<C-x>", '"+y<esc>dd', { desc = "Copy and delete line" })
map({ "n", "v" }, "<C-y>", '"+yy<esc>', { desc = "Copy" })

map({ "n" }, "<C-p>", '"+p<esc>', { noremap = true, desc = "Paste" })
map("v", "x", '"_x', { noremap = true, silent = true, desc = "Delete character without yanking" })
map(
  "n",
  "x", -- Also let's allow 'x' key to delete blank lines in normal mode.
  function()
    if vim.fn.col(".") == 1 then
      local line = vim.fn.getline(".")
      if line:match("^%s*$") then
        vim.api.nvim_feedkeys("dd", "n", false)
        vim.api.nvim_feedkeys("$", "n", false)
      else
        vim.api.nvim_feedkeys('"_x', "n", false)
      end
    else
      vim.api.nvim_feedkeys('"_x', "n", false)
    end
  end,
  { noremap = true, silent = true, desc = "Delete blank line without yanking" }
)
-- Blazingly fast way out of insert mode and terminal mode
map("i", "<C-c>", "<esc>")

map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Escape Insert Mode" })

-- Beter scrolllssssssss
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })

map("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
map("v", "<Tab>", ">gv", { desc = "Indent line" })

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- location list
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
