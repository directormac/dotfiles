return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			-- on_attach = function(buffer)
			-- 	-- local gs = package.loaded.gitsigns
			--
			-- 	local gs = require("gitsigns")
			--
			-- 	-- local function map(mode, l, r, desc)
			-- 	-- 	vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
			-- 	-- end
			--
			-- 	local function map(mode, l, r, opts)
			-- 		opts = opts or {}
			-- 		opts.buffer = buffer
			-- 		vim.keymap.set(mode, l, r, opts)
			-- 	end
			--
			--        -- stylua: ignore start
			--        map("n", "]h", function()
			--          if vim.wo.diff then
			--            vim.cmd.normal({ "]c", bang = true })
			--          else
			--            gs.nav_hunk("next")
			--          end
			--        end, "Next Hunk")
			--        map("n", "[h", function()
			--          if vim.wo.diff then
			--            vim.cmd.normal({ "[c", bang = true })
			--          else
			--            gs.nav_hunk("prev")
			--          end
			--        end, "Prev Hunk")
			--        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
			--        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
			--        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
			--        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
			--        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
			--        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
			--        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
			--        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
			--        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
			--        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
			--        map("n", "<leader>ghd", gs.diffthis, "Diff This")
			--        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
			--        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
			-- end,
			on_attach = function(buffer)
				local gitsigns = require("gitsigns")

				-- 	-- local function map(mode, l, r, desc)
				-- 	-- 	vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				-- 	-- end

				local function map(mode, l, r, desc)
					-- opts = opts or {}
					-- opts.buffer =buffer
					-- vim.keymap.set(mode, l, r, opts)

					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				-- Navigation
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, "Next Hunk")

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, "Prev Hunk")

			  -- stylua: ignore start
				map("n", "]H", function() gitsigns.nav_hunk("last") end, "Last Hunk")
				map("n", "[H", function() gitsigns.nav_hunk("first") end, "First Hunk")

				-- Actions
				map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage Hunk")
				map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset Hunk")

				map("v", "<leader>ghs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)

				map("v", "<leader>ghr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)

				map("n", "<leader>ghS", gitsigns.stage_buffer)
				map("n", "<leader>ghR", gitsigns.reset_buffer)
				map("n", "<leader>ghp", gitsigns.preview_hunk)
				map("n", "<leader>ghi", gitsigns.preview_hunk_inline)

				map("n", "<leader>ghb", function()
					gitsigns.blame_line({ full = true })
				end)

				map("n", "<leader>ghd", gitsigns.diffthis)

				map("n", "<leader>ghD", function()
					gitsigns.diffthis("~")
				end)

				map("n", "<leader>ghQ", function()
					gitsigns.setqflist("all")
				end)
				map("n", "<leader>ghq", gitsigns.setqflist)

				-- Toggles
				-- map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
				-- map("n", "<leader>td", gitsigns.toggle_deleted)
				-- map("n", "<leader>tw", gitsigns.toggle_word_diff)

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
			end,
		},
	},
	{
		"gitsigns.nvim",
		opts = function()
			Snacks.toggle({
				name = "Git Signs",
				get = function()
					return require("gitsigns.config").config.signcolumn
				end,
				set = function(state)
					require("gitsigns").toggle_signs(state)
				end,
			}):map("<leader>uG")
		end,
	},
}
