return {
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
        -- stylua: ignore
        { "<C-1>", function() require("bufferline").go_to(1, true) end, desc = "Go to first buffer", },
        -- stylua: ignore
        { "<C-2>", function() require("bufferline").go_to(2, true) end, desc = "Go to second buffer", },
        -- stylua: ignore
        { "<C-3>", function() require("bufferline").go_to(3, true) end, desc = "Go to third buffer", },
        -- stylua: ignore
        { "<C-4>", function() require("bufferline").go_to(4, true) end, desc = "Go to fourth buffer", },
        -- stylua: ignore
        { "<C-5>", function() require("bufferline").go_to(5, true) end, desc = "Go to fifth buffer", },
        -- stylua: ignore
        { "<C-6>", function() require("bufferline").go_to(6, true) end, desc = "Go to sixth buffer", },
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
			{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
		},
		opts = function(_, opts)
			opts.options = {
				indicator = { style = "none" },
				always_show_bufferline = true,
				separator_style = "thin",
				show_buffer_close_icons = false,
				show_duplicate_prefix = true,
				persist_buffer_sort = true,
				show_close_icon = false,
				offsets = {
					{
						filetype = "oil",
						text = "file explorer",
						highlight = "Directory",
						text_align = "left",
					},
				},
			}
		end,
	},
}
