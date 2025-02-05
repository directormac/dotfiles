local M = {}
local is_nixos = vim.fn.system("uname -r") == 0

if not is_nixos then
	M = {
		{
			"williamboman/mason.nvim",
			lazy = false,
			config = function()
				require("mason").setup({
					auto_install = true,
					ensure_installed = {
						"elixir-ls",
						"tailwindcss-language-server",
					},
				})
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			lazy = false,
			opts = {
				auto_install = true,
				-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
				ensure_installed = {
					"astro",
					"bashls",
					"biome",
					"css_variables",
					"cssls",
					"cssmodules_ls",
					-- "denols",
					"docker_compose_language_service",
					"dockerls",
					-- "elixirls",
					"emmet_ls",
					-- "erlangls",
					"eslint",
					"golangci_lint_ls",
					"gopls",
					"helm_ls",
					"html",
					"htmx",
					-- "java_language_server",
					"jdtls",
					"jqls",
					"jsonls",
					"kotlin_language_server",
					"lexical",
					"lua_ls",
					-- "markdown-oxide",
					-- "marksman",
					"nil_ls",
					"phpactor",
					"prismals",
					"ruff",
					"rust_analyzer",
					-- "slint_lsp",
					"svelte",
					"taplo",
					"terraformls",
					"textlsp",
					"ts_ls",
					"volar",
					"vtsls",
					-- "zls"
					-- Unknown
					-- "markdownlint-cli2",
					-- "markdown-toc",
				},
			},
			config = function(_, opts)
				require("mason-lspconfig").setup(opts)
			end,
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = { "saghen/blink.cmp" },
			opts = {
				servers = {
					lua_ls = {},
					ts_ls = {},
					svelte = {},
					nil_ls = {},
					elixirls = {},
					vtsls = {
						-- explicitly add default filetypes, so that we can extend
						-- them in related extras
						filetypes = {
							"javascript",
							"javascriptreact",
							"javascript.jsx",
							"typescript",
							"typescriptreact",
							"typescript.tsx",
						},
						settings = {
							complete_function_calls = true,
							vtsls = {
								enableMoveToFileCodeAction = true,
								autoUseWorkspaceTsdk = true,
								experimental = {
									maxInlayHintLength = 30,
									completion = {
										enableServerSideFuzzyMatch = true,
									},
								},
							},
							typescript = {
								updateImportsOnFileMove = { enabled = "always" },
								suggest = {
									completeFunctionCalls = true,
								},
								inlayHints = {
									enumMemberValues = { enabled = true },
									functionLikeReturnTypes = { enabled = true },
									parameterNames = { enabled = "literals" },
									parameterTypes = { enabled = true },
									propertyDeclarationTypes = { enabled = true },
									variableTypes = { enabled = false },
								},
							},
						},
					},
				},
			},
			config = function(_, opts)
				local lspconfig = require("lspconfig")
				for server, config in pairs(opts.servers) do
					-- passing config.capabilities to blink.cmp merges with the capabilities in your
					-- `opts[server].capabilities, if you've defined it
					config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
					lspconfig[server].setup(config)
				end
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				local configs = require("nvim-treesitter.configs")

				configs.setup({
					ensure_installed = {
						"astro",
						"bash",
						"c",
						"cpp",
						"css",
						"elixir",
						"eex",
						"gleam",
						"go",
						"graphql",
						"heex",
						"html",
						"html",
						"java",
						"javascript",
						"javascript",
						"json",
						"jsonc",
						"kotlin",
						"lua",
						"lua",
						"markdown",
						"markdown_inline",
						"prisma",
						"query",
						"regex",
						"slint",
						"sql",
						"svelte",
						"svelte",
						"tsx",
						"typescript",
						"vim",
						"vim",
						"vimdoc",
						"vue",
						"xml",
						"yaml",
					},
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },

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
				})
			end,
		},
		-- {
		-- 	"nvim-treesitter/nvim-treesitter",
		-- 	build = ":TSUpdate",
		-- 	keys = {
		-- 		{ "<c-space>", desc = "Increment Selection" },
		-- 		{ "<bs>", desc = "Decrement Selection", mode = "x" },
		-- 	},
		-- 	config = function()
		-- 		local config = require("nvim-treesitter.configs")
		-- 		config.setup({
		-- 			highlight = { enable = true },
		-- 			indent = { enable = true },
		-- 			auto_install = false,
		-- 			ensure_installed = {
		-- 				"astro",
		-- 				"bash",
		-- 				"css",
		-- 				"cpp",
		-- 				"elixir",
		-- 				"go",
		-- 				"html",
		-- 				"gleam",
		-- 				"graphql",
		-- 				"javascript",
		-- 				"json",
		-- 				"jsonc",
		-- 				"lua",
		-- 				"markdown",
		-- 				"markdown_inline",
		-- 				"prisma",
		-- 				"svelte",
		-- 				"sql",
		-- 				"java",
		-- 				"kotlin",
		-- 				"regex",
		-- 				"slint",
		-- 				"svelte",
		-- 				"tsx",
		-- 				"typescript",
		-- 				"vue",
		-- 				"vim",
		-- 				"yaml",
		-- 				"xml",
		-- 			},
		-- 			-- incremental_selection = {
		-- 			-- 	enable = true,
		-- 			-- 	keymaps = {
		-- 			-- 		init_selection = "<C-space>",
		-- 			-- 		node_incremental = "<C-space>",
		-- 			-- 		scope_incremental = false,
		-- 			-- 		node_decremental = "<bs>",
		-- 			-- 	},
		-- 			-- },
		-- 			-- textobjects = {
		-- 			-- 	move = {
		-- 			-- 		enable = true,
		-- 			-- 		goto_next_start = {
		-- 			-- 			["]f"] = "@function.outer",
		-- 			-- 			["]c"] = "@class.outer",
		-- 			-- 			["]a"] = "@parameter.inner",
		-- 			-- 		},
		-- 			-- 		goto_next_end = {
		-- 			-- 			["]F"] = "@function.outer",
		-- 			-- 			["]C"] = "@class.outer",
		-- 			-- 			["]A"] = "@parameter.inner",
		-- 			-- 		},
		-- 			-- 		goto_previous_start = {
		-- 			-- 			["[f"] = "@function.outer",
		-- 			-- 			["[c"] = "@class.outer",
		-- 			-- 			["[a"] = "@parameter.inner",
		-- 			-- 		},
		-- 			-- 		goto_previous_end = {
		-- 			-- 			["[F"] = "@function.outer",
		-- 			-- 			["[C"] = "@class.outer",
		-- 			-- 			["[A"] = "@parameter.inner",
		-- 			-- 		},
		-- 			-- 	},
		-- 			-- },
		-- 		})
		-- 	end,
		-- },
	}
end

return M
