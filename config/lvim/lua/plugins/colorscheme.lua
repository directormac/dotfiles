return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {

			terminal_colors = true,
			falvour = "mocha",
			background = { -- :h background
				light = "latte",
				dark = "mocha",
			},
			transparent_background = true,
			float = {
				transparent = true,
				solid = false,
			},

			integrations = {
				bufferline = true,
				snacks = true,
				which_key = true,
				notify = true,
				grug_far = false,
				fidget = false,
				blink_cmp = {
					style = "bordered",
				},
			},
			auto_integrations = true,
		},
		{
			"folke/tokyonight.nvim",
			opts = {
				transparent = true,
				terminal_colors = true,
				style = "night",
				light_style = "night",
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
			},
		},
		{
			"LazyVim/LazyVim",
			opts = {
				colorscheme = "catppuccin-nvim",
				-- colorscheme = "tokyonight",
			},
		},
	},
}
