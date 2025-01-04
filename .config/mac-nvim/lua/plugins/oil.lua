return {
	{
		"stevearc/oil.nvim",
		commit = "50c4bd4ee216f08907f64d0295c0663a69e58ffb",
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
		event = "VeryLazy",
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
	},
}
