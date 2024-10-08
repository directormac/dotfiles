------------------------------------------------------
--               Wezterm configuration
------------------------------------------------------

local term = require("wezterm")
local act = term.action
local gui = term.gui
local mux = term.mux

local windows = require("windows") -- file located at ~/.config/wezterm/windows.lua
local linux = require("linux") -- file located at ~/.config/wezterm/linux.lua
local terminal = require("terminal")
local keymaps = require("keymaps")

local config = {}

-- For windows host custom configuration
if term.target_triple == "x86_64-pc-windows-msvc" then
	windows.options(config)
end

-- For linux host custom configuration
if term.target_triple == "x86_64-unknown-linux-gnu" then
	linux.options(config)
end

--Startup settings
term.on("gui-startup", function(cmd)
	local mode = os.getenv("MODE")

	if mode == "float" then
		config.font_size = 20
		-- term.initial_cols = 120
		-- term.initial_rows = 50
		-- local tab, pane, window = mux.spawn_window(cmd or {})
		-- window:gui_window():set_inner_size(1280, 720)
		-- window:gui_window():set_position("main:50%:50%")
		-- window:maximize()
		-- pane:split({ direction = "Bottom", size = 0.25 })
	end

	-- local tab, pane, window = mux.spawn_window(cmd or {})
	-- window:gui_window():set_inner_size(1280, 720)
	-- window:gui_window():set_position("main:50%:50%")
	-- window:maximize()
	-- pane:split({ direction = "Bottom", size = 0.25 })

	-- local tab, pane, window = mux.spawn_window(cmd or {})
	-- window:gui_window():set_inner_size(1280, 720)
	-- window:gui_window():set_position("main:50%:50%")
	-- window:maximize()
	-- pane:split({ direction = "Bottom", size = 0.25 })
end)

term.on("mux-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():set_inner_size(1280, 720)
	window:gui_window():set_position(980, 59)
	pane:split({ direction = "Bottom", size = 0.25 })
end)

terminal.options(config)
keymaps.options(config)

--------------------------------------
-- Local Functions
--------------------------------------
local function recompute_padding(window)
	local window_dims = window:get_dimensions()
	local overrides = window:get_config_overrides() or {}

	if not window_dims.is_full_screen then
		if not overrides.window_padding then
			-- not changing anything
			return
		end
		overrides.window_padding = nil
	else
		-- Use only the middle 33%
		local third = math.floor(window_dims.pixel_width / 3)
		local new_padding = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0,
		}
		if overrides.window_padding and new_padding.left == overrides.window_padding.left then
			-- padding is same, avoid triggering further changes
			return
		end
		overrides.window_padding = new_padding
	end
	window:set_config_overrides(overrides)
end

term.on("window-resized", function(window, pane)
	recompute_padding(window)
end)
term.on("window-config-reloaded", function(window)
	recompute_padding(window)
end)

local function basename(path)
	local trimmed_path = path:gsub("[/\\]*$", "") ---Remove trailing slashes from the path
	local index = trimmed_path:find("[^/\\]*$") ---Find the last occurrence of '/' in the path

	return index and trimmed_path:sub(index) or trimmed_path
end

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

term.on("format-tab-title", function(tab)
	-- local cwd = basename(tab.active_pane.current_working_dir)

	-- local tab_index = string.format("  %s  ", tab.tab_index + 1)
	--
	-- return term.format({
	-- 	-- { Text = "▏" },
	-- 	{ Text = tab_index },
	-- })

	local title = tab_title(tab)

	local max = config.tab_max_width - 9
	if #title > max then
		title = term.truncate_right(title, max) .. "…"
	end

	return {
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = " " .. (tab.tab_index + 1) .. ": " .. title .. " " },
	}
end)

term.on("update-right-status", function(window, pane)
	local cells = {}
	local key_mode = window:active_key_table()
	local mode = {
		["search_mode"] = "󰜏",
		["copy_mode"] = "",
	}
	if not key_mode then
		table.insert(cells, "")
	else
		table.insert(cells, mode[key_mode])
	end

	--
	local workspace = window:active_workspace()
	if workspace == "default" then
		workspace = ""
	end
	table.insert(cells, workspace)

	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		cwd_uri = cwd_uri:sub(8)
		local slash = cwd_uri:find("/")
		local cwd = ""
		local hostname = ""
		if slash then
			hostname = cwd_uri:sub(1, slash - 1)
			-- Remove the domain name portion of the hostname
			local dot = hostname:find("[.]")
			if dot then
				hostname = hostname:sub(1, dot - 1)
			end
			-- and extract the cwd from the uri
			cwd = cwd_uri:sub(slash)
			-- table.insert(cells, cwd)
			if hostname == "" then
				table.insert(cells, "")
			elseif string.find(hostname, "arch") then
				table.insert(cells, "")
			else
				table.insert(cells, "")
			end
		end
	end
	local current_time = tonumber(term.strftime("%H"))
	-- stylua: ignore
	local time = {
		[00] = "",
		[01] = "",
		[02] = "",
		[03] = "",
		[04] = "",
		[05] = "",
		[06] = "",
		[07] = "",
		[08] = "",
		[09] = "",
		[10] = "󰗲",
		[11] = "",
		[12] = "",
		[13] = "",
		[14] = "",
		[15] = "",
		[16] = "",
		[17] = "",
		[18] = "",
		[19] = "󰗲",
		[20] = "",
		[21] = "",
		[22] = "",
		[23] = "",
	}
	local date = term.strftime("%H:%M:%S %a %b %d ")
	local date_time = time[current_time] .. " " .. date
	table.insert(cells, date_time)
	local text_fg = terminal.colors.transparent
	-- local SEPERATOR = " █"
	local SEPERATOR = "  "
	local pallete = {
		"#f7768e",
		"#9ece6a",
		"#7dcfff",
		"#bb9af7",
		"#e0af68",
		"#7aa2f7",
	}
	local cols = pane:get_dimensions().cols
	local padding = term.pad_right("", (cols / 2) - string.len(date_time) - 2)
	local elements = {}
	local num_cells = 0

	-- Translate into elements
	function push(text, is_last)
		local cell_no = num_cells + 1
		if is_last then
			-- table.insert(elements, text_fg)
			table.insert(elements, { Text = padding })
		end
		table.insert(elements, { Foreground = { Color = pallete[cell_no] } })
		table.insert(elements, { Background = { Color = terminal.colors.transparent } })
		table.insert(elements, { Text = "" .. text .. "" })
		if not is_last then
			table.insert(elements, { Foreground = { Color = terminal.colors.transparent } })
			table.insert(elements, { Background = { Color = terminal.colors.transparent } })
			table.insert(elements, { Text = SEPERATOR })
		end
		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end
	window:set_right_status(term.format(elements))
end)

return config
