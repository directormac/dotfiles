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
function recompute_padding(window)
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

return config
