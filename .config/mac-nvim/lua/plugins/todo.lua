return {
	-- {
	-- 	"folke/todo-comments.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	cmd = { "TodoTrouble", "TodoTelescope" },
	-- 	event = "LazyFile",
	-- 	opts = {},
	--    -- stylua: ignore
	--    keys = {
	--      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
	--      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
	--      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
	--      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
	--      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
	--      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
	--    },
	-- },
	{
		"folke/todo-comments.nvim",
		-- optional = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous Todo Comment",
			},
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Todo/Fix/Fixme (Trouble)",
			},
			{
				"<leader>st",
				function()
					Snacks.picker.todo_comments()
				end,
				desc = "Todo",
			},
			{
				"<leader>sT",
				function()
					Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
				end,
				desc = "Todo/Fix/Fixme",
			},
		},
		opts = {},
	},
}
