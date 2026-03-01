return {
	-- {
	--   "folke/tokyonight.nvim",
	--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
	--   priority = 1000, -- make sure to load this before all the other start plugins
	--   config = function()
	--     -- load the colorscheme here
	--     vim.cmd([[colorscheme tokyonight]])
	--   end,
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			transparent_background = true,
			float = {
				transparent = true,
				solid = true,
			},
			falvour = "mocha",
			color_overrides = {
				all = {
					base = "#11111B",
					mantle = "#11111B",
				},
			},
			custom_highlights = function(colors)
				return {
					-- Comment = { fg = colors.flamingo },
					RenderMarkdownCode = { bg = colors.mantle },
				}
			end,
		},

		-- show_end_of_buffer = false,
		term_colors = true,
	},
}
