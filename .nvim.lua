-- 1. Define the custom LSP configuration for tmux
vim.lsp.config("tmux_ls", {
	cmd = { "tmux-language-server" },
	filetypes = { "tmux" },
	root_markers = { ".git", ".tmux.conf", "tmux.conf" },
})

-- 2. Enable it globally (automatically attaches when filetype matches)
vim.lsp.enable("tmux_ls")

vim.filetype.add({
	pattern = {
		[".*tmux%.conf"] = "tmux",
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

		-- Example keymaps for navigation/inspection
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "rounded", silent = true }) end, opts)

		-- Enable built-in completion if supported
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- vim.treesitter.language.add('python', { path = "" })
vim.treesitter.language.register("tmux", { "conf", "tmux" })
