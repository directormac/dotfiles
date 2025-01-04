return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
    -- stylua: ignore
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    },
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			dashboard = {
				preset = {
					header = [[

 █████╗ ██████╗ ████████╗██╗███████╗███████╗██╗  ██╗
██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝╚██╗██╔╝
███████║██████╔╝   ██║   ██║█████╗  █████╗   ╚███╔╝ 
██╔══██║██╔══██╗   ██║   ██║██╔══╝  ██╔══╝   ██╔██╗ 
██║  ██║██║  ██║   ██║   ██║██║     ███████╗██╔╝╚██╗
╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
ɔɐɯɹoʇɔǝɹᴉp
         

        ]],
              -- stylua: ignore
              ---@type snacks.dashboard.Item[]
      keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
              },
				},
			},
			-- terminal = {
			-- 	win = {
			-- 		keys = {
			-- 			nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
			-- 			nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
			-- 			nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
			-- 			nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
			-- 		},
			-- 	},
			-- },
		},
	},
}
