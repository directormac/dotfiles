---@module "mappings.default"

---@diagnostic disable-next-line: undefined-field
local act = require("wezterm").action
local key = require("utils.fn").key

local workspace_switcher =
  require("wezterm").plugin.require "https://github.com/MLFlexer/smart_workspace_switcher.wezterm"

local Config = {}

Config.disable_default_key_bindings = true
-- Config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
Config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

local mappings = {
  -- Clipboard
  { "<C-S-c>", act.CopyTo "Clipboard", "copy" },
  { "<C-S-v>", act.PasteFrom "Clipboard", "paste" },

  -- Navigation
  { "<C-Tab>", act.ActivateTabRelative(1), "next tab" },
  { "<C-S-Tab>", act.ActivateTabRelative(-1), "prev tab" },

  { "<C-CR>", act.ToggleFullScreen, "fullscreen" },

  -- Tabs and Window
  { "<C-S-n>", act.SpawnWindow, "new window" },
  { "<C-S-p>", act.ActivateCommandPalette, "command palette" },
  { "<C-S-r>", act.ReloadConfiguration, "reload config" },
  { "<C-S-t>", act.SpawnTab "CurrentPaneDomain", "new pane" },

  -- Others
  { "<C-S-f>", act.Search "CurrentSelectionOrEmptyString", "search" },
  { "<C-S-k>", act.ClearScrollback "ScrollbackOnly", "clear scrollback" },
  { "<C-S-l>", act.ShowDebugOverlay, "debug overlay" },
  {
    "<C-S-u>",
    act.CharSelect {
      copy_on_select = true,
      copy_to = "ClipboardAndPrimarySelection",
    },
    "char select",
  },
  { "<C-S-w>", act.CloseCurrentTab { confirm = true }, "close tab" },
  { "<C-S-z>", act.TogglePaneZoomState, "toggle zoom" },
  { "<PageUp>", act.ScrollByPage(-1), "" },
  { "<PageDown>", act.ScrollByPage(1), "" },
  { "<C-S-Insert>", act.PasteFrom "PrimarySelection", "" },
  { "<C-Insert>", act.CopyTo "PrimarySelection", "" },
  { "<C-S-Space>", act.QuickSelect, "quick select" },
  {
    "<S-M-t>",
    act.ShowLauncherArgs {
      title = "  Search:",
      flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
    },
    "new window",
  },

  ---quick split and nav
  { '<C-S-">', act.SplitHorizontal { domain = "CurrentPaneDomain" }, "vsplit" },
  { "<C-S-%>", act.SplitVertical { domain = "CurrentPaneDomain" }, "hsplit" },
  { "<C-M-h>", act.ActivatePaneDirection "Left", "move left" },
  { "<C-M-j>", act.ActivatePaneDirection "Down", "mode down" },
  { "<C-M-k>", act.ActivatePaneDirection "Up", "move up" },
  { "<C-M-l>", act.ActivatePaneDirection "Right", "move right" },

  ---key tables
  { "<leader>h", act.ActivateKeyTable { name = "help_mode", one_shot = true }, "help" },
  {
    "<leader>w",
    act.ActivateKeyTable { name = "window_mode", one_shot = false },
    "window mode",
  },
  {
    "<leader>f",
    act.ActivateKeyTable { name = "font_mode", one_shot = false },
    "font mode",
  },
  { "<leader>c", act.ActivateCopyMode, "copy mode" },
  { "<leader>s", act.Search "CurrentSelectionOrEmptyString", "search mode" },
  { "<leader>p", act.ActivateKeyTable { name = "pick_mode" }, "pick mode" },
}

for i = 1, 24 do
  mappings[#mappings + 1] =
    { "<S-F" .. i .. ">", act.ActivateTab(i - 1), "activate tab " .. i }
end

for _, map_tbl in ipairs(mappings) do
  key.map(map_tbl[1], map_tbl[2], Config.keys)
end

local fuzzy_workspaces =
  act.ShowLauncherArgs { title = " Workspaces", flags = "FUZZY|WORKSPACES" }

Config.keys = {

  { key = "w", mods = "LEADER", action = fuzzy_workspaces },
  { key = "t", mods = "LEADER", action = workspace_switcher.switch_workspace() },
  { key = "Tab", mods = "CTRL", action = act { ActivateTabRelative = 1 } },
  { key = "1", mods = "LEADER", action = act { ActivateTab = 0 } },
  { key = "2", mods = "LEADER", action = act { ActivateTab = 1 } },
  { key = "3", mods = "LEADER", action = act { ActivateTab = 2 } },
  { key = "4", mods = "LEADER", action = act { ActivateTab = 3 } },
  { key = "5", mods = "LEADER", action = act { ActivateTab = 4 } },
  { key = "6", mods = "LEADER", action = act { ActivateTab = 5 } },
  { key = "7", mods = "LEADER", action = act { ActivateTab = 6 } },
  { key = "8", mods = "LEADER", action = act { ActivateTab = 7 } },
  { key = "9", mods = "LEADER", action = act { ActivateTab = 8 } },
  { key = "1", mods = "CTRL", action = act { ActivateTab = 0 } },
  { key = "2", mods = "CTRL", action = act { ActivateTab = 1 } },
  { key = "3", mods = "CTRL", action = act { ActivateTab = 2 } },
  { key = "4", mods = "CTRL", action = act { ActivateTab = 3 } },
  { key = "5", mods = "CTRL", action = act { ActivateTab = 4 } },
  { key = "6", mods = "CTRL", action = act { ActivateTab = 5 } },
  { key = "7", mods = "CTRL", action = act { ActivateTab = 6 } },
  { key = "8", mods = "CTRL", action = act { ActivateTab = 7 } },
  { key = "9", mods = "CTRL", action = act { ActivateTab = 8 } },
  { key = "h", mods = "CTRL", action = act { ActivateTabRelative = -1 } },
  { key = "l", mods = "CTRL", action = act { ActivateTabRelative = 1 } },
  { key = ">", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "<", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "h", mods = "LEADER", action = act { ActivatePaneDirection = "Left" } },
  { key = "j", mods = "LEADER", action = act { ActivatePaneDirection = "Down" } },
  { key = "k", mods = "LEADER", action = act { ActivatePaneDirection = "Up" } },
  { key = "l", mods = "LEADER", action = act { ActivatePaneDirection = "Right" } },

  { key = "H", mods = "LEADER|SHIFT", action = act { AdjustPaneSize = { "Left", 5 } } },
  { key = "J", mods = "LEADER|SHIFT", action = act { AdjustPaneSize = { "Down", 5 } } },
  { key = "K", mods = "LEADER|SHIFT", action = act { AdjustPaneSize = { "Up", 5 } } },
  { key = "L", mods = "LEADER|SHIFT", action = act { AdjustPaneSize = { "Right", 5 } } },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },
  {
    key = "-",
    mods = "LEADER",
    action = act { SplitVertical = { domain = "CurrentPaneDomain" } },
  },
  {
    key = "=",
    mods = "LEADER",
    action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } },
  },
  { key = "c", mods = "LEADER", action = act { SpawnTab = "CurrentPaneDomain" } },
  { key = "q", mods = "LEADER", action = act.PaneSelect },
  { key = "n", mods = "LEADER", action = act.SpawnWindow },
  {
    key = "F8",
    action = term.action_callback(function(window)
      window:maximize()
    end),
  },
  { key = "F7", action = act.Hide },
  { key = "F11", action = act.ToggleFullScreen },
}

Config.mouse_bindings = {
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
    action = require("wezterm").action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo "ClipboardAndPrimarySelection", pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act { PasteFrom = "Clipboard" }, pane)
      end
    end),
  },
}

return Config
