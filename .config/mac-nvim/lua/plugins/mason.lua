local M = {}
local is_nixos = vim.fn.system("uname -r") == 0

if not is_nixos then
	M = {
		{
			"williamboman/mason.nvim",
			-- dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
			opts = {},
		},
		{
			"williamboman/mason-lspconfig.nvim",
			opts = {
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
					"elixirls",
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
				automatic_installation = true,
			},
		},
	}
end

return M
