return {
	"stevearc/oil.nvim",
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	keys = {
		{
			"<leader>fo",
			"<cmd>Oil<cr>",
			{ desc = "Oil explorer on current buffer directory" },
		},
		{
			"<leader>fO",
			"<cmd>Oil .<cr>",
			{ desc = "Oil explorer on current buffer directory" },
		},
	},
	-- event = "VeryLazy",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		default_file_explorer = true,
		columns = {
			"icon",
			"size",
		},
		-- Skip the confirmation popup for simple operations
		skip_confirm_for_simple_edits = true,
		keymaps = {
			["q"] = "actions.close",
			["<C-s>"] = false,
		},
		view_options = {
			show_hidden = true,
		},
	},
}
