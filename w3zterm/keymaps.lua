local term = require("wezterm")
local act = term.action
local gui = term.gui

local M = {}

function M.options(config)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	local fuzzy_commands =
		act.ShowLauncherArgs({ title = "  Fuzzy Commands", flags = "FUZZY|KEY_ASSIGNMENTS|COMMANDS" })
	local fuzzy_domains =
		act.ShowLauncherArgs({ title = "  Find Domains", flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS" })
	local fuzzy_tabs = act.ShowLauncherArgs({ title = " Tabs", flags = "FUZZY|WORKSPACES|TABS" })
	config.keys = {
		{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "ClipboardAndPrimarySelection" }) },
		{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },
		{ key = "F10", action = fuzzy_domains },
		{ key = "F11", action = act.ToggleFullScreen },
		{ key = "F12", action = fuzzy_commands },
		{ key = "F9", action = fuzzy_tabs },
		{ key = "F7", action = act.Hide },
		{
			key = "F8",
			action = term.action_callback(function(window)
				window:maximize()
			end),
		},
		-- { key = "Escape", mods = "LEADER", action = act.QuitApplication },
		{ key = "-", mods = "LEADER", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "0", mods = "LEADER", action = act.ResetFontAndWindowSize },
		{ key = "Tab", mods = "LEADER", action = act.SwitchToWorkspace },
		{ key = "\\", mods = "LEADER", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		{ key = "c", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "f", mods = "LEADER", action = "QuickSelect" },
		{ key = "h", mods = "LEADER", action = act({ ActivatePaneDirection = "Left" }) },
		{ key = "j", mods = "LEADER", action = act({ ActivatePaneDirection = "Down" }) },
		{ key = "k", mods = "LEADER", action = act({ ActivatePaneDirection = "Up" }) },
		{ key = "l", mods = "LEADER", action = act({ ActivatePaneDirection = "Right" }) },
		{ key = "n", mods = "LEADER", action = act.SpawnWindow },
		{ key = "o", mods = "LEADER", action = fuzzy_domains },
		{ key = "p", mods = "LEADER", action = fuzzy_commands },
		{ key = "q", mods = "LEADER", action = act.PaneSelect },
		{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
		{ key = "s", mods = "LEADER", action = act({ Search = { CaseInSensitiveString = "" } }) },
		{ key = "w", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
		{ key = "y", mods = "LEADER", action = "ActivateCopyMode" },
		{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
		{ key = ">", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(0) },
		{ key = "<", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(-2) },
		{ key = "H", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Left", 5 } }) },
		{ key = "J", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Down", 5 } }) },
		{ key = "K", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Up", 5 } }) },
		{ key = "L", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Right", 5 } }) },
		{ key = "-", mods = "LEADER|CTRL", action = act.DecreaseFontSize },
		{ key = "=", mods = "LEADER|CTRL", action = act.IncreaseFontSize },
		{ key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
		{ key = "1", mods = "ALT", action = act({ ActivateTab = 0 }) },
		{ key = "2", mods = "ALT", action = act({ ActivateTab = 1 }) },
		{ key = "3", mods = "ALT", action = act({ ActivateTab = 2 }) },
		{ key = "4", mods = "ALT", action = act({ ActivateTab = 3 }) },
		{ key = "5", mods = "ALT", action = act({ ActivateTab = 4 }) },
		{ key = "6", mods = "ALT", action = act({ ActivateTab = 5 }) },
		{ key = "7", mods = "ALT", action = act({ ActivateTab = 6 }) },
		{ key = "8", mods = "ALT", action = act({ ActivateTab = 7 }) },
		{ key = "9", mods = "ALT", action = act({ ActivateTab = 8 }) },
	}

	-- copy_mode
	local copy_mode = gui.default_key_tables().copy_mode
	table.insert(copy_mode, { key = "h", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") })
	table.insert(copy_mode, { key = "l", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") })
	table.insert(copy_mode, {
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			act.CopyTo("PrimarySelection"),
			act.ClearSelection,
			act.CopyMode("ClearSelectionMode"),
		}),
	})
	-- search_mode
	local search_mode = gui.default_key_tables().search_mode
	table.insert(search_mode, { key = "c", mods = "CTRL", action = act.CopyMode("Close") })

	-- copy_mode <=> search_mode
	table.insert(copy_mode, { key = "/", mods = "NONE", action = act.Search({ CaseInSensitiveString = "" }) })
	table.insert(search_mode, { key = "Enter", mods = "SHIFT", action = act.ActivateCopyMode })

	config.key_tables = {
		copy_mode = copy_mode,
		search_mode = search_mode,
		super = {
			{ key = "`", mods = "CTRL", action = "PopKeyTable" },
			{ key = "Space", mods = "NONE", action = act.Search({ CaseInSensitiveString = "" }) },
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
			{ key = "s", mods = "CTRL", action = act.CopyMode("ClearPattern") },
			{
				key = "Escape",
				mods = "NONE",
				action = act.Multiple({ act.CopyMode("Close"), "PopKeyTable" }),
			},
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
			{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "K", mods = "CTRL", action = act.ScrollByPage(-0.5) },
			{ key = "J", mods = "CTRL", action = act.ScrollByPage(1) },
			{ key = "k", mods = "CTRL", action = act.ScrollByLine(-1) },
			{ key = "j", mods = "CTRL", action = act.ScrollByLine(1) },
			{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "ClipboardAndPrimarySelection" }) },
		},
	}

	config.mouse_bindings = {
		-- Scrolling up while holding CTRL increases the font size
		{
			event = { Down = { streak = 1, button = { WheelUp = 1 } } },
			mods = "CTRL",
			action = act.IncreaseFontSize,
		},

		-- Scrolling down while holding CTRL decreases the font size
		{
			event = { Down = { streak = 1, button = { WheelDown = 1 } } },
			mods = "CTRL",
			action = act.DecreaseFontSize,
		},
		{
			event = { Down = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = term.action_callback(function(window, pane)
				local has_selection = window:get_selection_text_for_pane(pane) ~= ""
				if has_selection then
					window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
					window:perform_action(act.ClearSelection, pane)
				else
					window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
				end
			end),
		},
	}
end

return M
