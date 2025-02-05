return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {
			transparent_background = true,
			falvour = "mocha",
			color_overrides = {
				all = {
					base = "#11111B",
					mantle = "#11111B",
				},
			},
			integrations = {
				aerial = true,
				alpha = true,
				cmp = true,
				dashboard = true,
				flash = true,
				fzf = true,
				grug_far = true,
				gitsigns = true,
				headlines = true,
				illuminate = true,
				indent_blankline = { enabled = true },
				leap = true,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				navic = { enabled = true, custom_bg = "lualine" },
				neotest = true,
				neotree = true,
				noice = true,
				notify = true,
				semantic_tokens = true,
				snacks = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
		},
		show_end_of_buffer = false,
		term_colors = true,
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
	{
		"folke/tokyonight.nvim",
		opts = {
			transparent = true,
			terminal_colors = true,
			style = "storm",
			light_style = "storm",
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
}
