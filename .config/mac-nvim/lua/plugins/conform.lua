return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		opts = {},
		-- opts = function(_, opts)
		-- 	opts.formatters_by_ft = opts.formatters_by_ft or {}
		-- 	for _, ft in ipairs(supported) do
		-- 		opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
		-- 		table.insert(opts.formatters_by_ft[ft], "prettier")
		-- 	end
		--
		-- 	opts.formatters = opts.formatters or {}
		-- 	opts.formatters.prettier = {
		-- 		condition = function(_, ctx)
		-- 			return M.has_parser(ctx) and (vim.g.lazyvim_prettier_needs_config ~= true or M.has_config(ctx))
		-- 		end,
		-- 	}
		-- end,
	},
}
