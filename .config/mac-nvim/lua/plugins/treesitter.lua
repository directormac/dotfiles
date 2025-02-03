local M = {}
local is_nixos = vim.fn.system("uname -r") == 0

if not is_nixos then
	M = {
		{
			"nvim-treesitter/nvim-treesitter",
			version = false,
			opts = {
				highlight = { enable = true },
				indent = { enable = true },
				auto_install = true,
				ensure_installed = {
					"astro",
					"bash",
					"css",
					"cpp",
					"elixir",
					"html",
					"gleam",
					"graphql",
					"javascript",
					"json",
					"jsonc",
					"lua",
					"markdown",
					"markdown_inline",
					"prisma",
					"svelte",
					"sql",
					"java",
					"kotlin",
					"regex",
					"slint",
					"svelte",
					"tsx",
					"typescript",
					"vue",
					"vim",
					"yaml",
					"xml",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				textobjects = {
					move = {
						enable = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
						},
					},
				},
			},
		},
	}
end

return M
