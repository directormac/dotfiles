-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")


-- https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h

-- #define XKB_KEY_space                         0x0020  /* U+0020 SPACE */
-- #define XKB_KEY_exclam                        0x0021  /* U+0021 EXCLAMATION MARK */
-- #define XKB_KEY_quotedbl                      0x0022  /* U+0022 QUOTATION MARK */
-- #define XKB_KEY_numbersign                    0x0023  /* U+0023 NUMBER SIGN */
-- #define XKB_KEY_dollar                        0x0024  /* U+0024 DOLLAR SIGN */
-- #define XKB_KEY_percent                       0x0025  /* U+0025 PERCENT SIGN */
-- #define XKB_KEY_ampersand                     0x0026  /* U+0026 AMPERSAND */
-- #define XKB_KEY_apostrophe                    0x0027  /* U+0027 APOSTROPHE */
-- #define XKB_KEY_quoteright                    0x0027  /* deprecated */
-- #define XKB_KEY_parenleft                     0x0028  /* U+0028 LEFT PARENTHESIS */
-- #define XKB_KEY_parenright                    0x0029  /* U+0029 RIGHT PARENTHESIS */
-- #define XKB_KEY_asterisk                      0x002a  /* U+002A ASTERISK */
-- #define XKB_KEY_plus                          0x002b  /* U+002B PLUS SIGN */
-- #define XKB_KEY_comma                         0x002c  /* U+002C COMMA */
-- #define XKB_KEY_minus                         0x002d  /* U+002D HYPHEN-MINUS */
-- #define XKB_KEY_period                        0x002e  /* U+002E FULL STOP */
-- #define XKB_KEY_slash                         0x002f  /* U+002F SOLIDUS */
-- #define XKB_KEY_0                             0x0030  /* U+0030 DIGIT ZERO */
-- #define XKB_KEY_1                             0x0031  /* U+0031 DIGIT ONE */
-- #define XKB_KEY_2                             0x0032  /* U+0032 DIGIT TWO */
-- #define XKB_KEY_3                             0x0033  /* U+0033 DIGIT THREE */
-- #define XKB_KEY_4                             0x0034  /* U+0034 DIGIT FOUR */
-- #define XKB_KEY_5                             0x0035  /* U+0035 DIGIT FIVE */
-- #define XKB_KEY_6                             0x0036  /* U+0036 DIGIT SIX */
-- #define XKB_KEY_7                             0x0037  /* U+0037 DIGIT SEVEN */
-- #define XKB_KEY_8                             0x0038  /* U+0038 DIGIT EIGHT */
-- #define XKB_KEY_9                             0x0039  /* U+0039 DIGIT NINE */
-- #define XKB_KEY_colon                         0x003a  /* U+003A COLON */
-- #define XKB_KEY_semicolon                     0x003b  /* U+003B SEMICOLON */
-- #define XKB_KEY_less                          0x003c  /* U+003C LESS-THAN SIGN */
-- #define XKB_KEY_equal                         0x003d  /* U+003D EQUALS SIGN */
-- #define XKB_KEY_greater                       0x003e  /* U+003E GREATER-THAN SIGN */
-- #define XKB_KEY_question                      0x003f  /* U+003F QUESTION MARK */
-- #define XKB_KEY_at                            0x0040  /* U+0040 COMMERCIAL AT */

-- hl.bind("SUPER + H",  function ()
--   hl.dsp.exec_cmd("omarchy-shell shell toggle io.github.chris.window-hints '{}'")
--   hl.dsp.submap("hints")
-- end
-- )
--
-- hl.define_submap("hints", function()
--
--
--     local function key(k)
--         return hl.dsp.exec_cmd("omarchy-shell window-hints key " .. k)
--     end
--
--     for _, ch in ipairs({ "a", "s", "d", "f", "g", "h", "j", "k", "l" }) do
--         hl.bind(ch, key(ch))
--         hl.bind("SHIFT + " .. ch, key(string.upper(ch)))
--     end
--
--     hl.bind("x", key("x"))
--     for n = 1, 9 do
--         hl.bind(tostring(n), key(tostring(n)))
--     end
--
--     hl.bind("escape", function()
--         hl.dispatch(key("escape"))
--         hl.dispatch(hl.dsp.submap("reset"))
--     end)
--     hl.bind("catchall", hl.dsp.no_op())
-- end)


hl.unbind("SUPER + RETURN")
-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
-- o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
-- o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
-- o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
-- o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

-- Bindings for preinstalled Omarchy applications, TUIs, and web apps.
-- o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
-- o.bind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
-- o.bind("SUPER + SHIFT + M", "Music", { omarchy = "spotify" })
-- o.bind("SUPER + SHIFT + ALT + M", "Music TUI", { tui = "cliamp", focus = true })
-- o.bind("SUPER + SHIFT + D", "Docker", { tui = "omarchy-launch-docker-tui" })
-- o.bind("SUPER + SHIFT + G", "Signal", { omarchy = "signal" })
-- o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
-- o.bind("SUPER + SHIFT + W", "Omawrite", { launch = "omawrite" })
-- o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })
--
-- o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
-- o.bind("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
-- o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
-- o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
-- o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
-- o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
-- o.bind("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
-- o.bind( "SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
-- o.bind("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
-- o.bind("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
-- o.bind("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
-- o.bind("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })


o.bind("SUPER + W", "Close window", hl.dsp.window.close())
o.bind("CTRL + ALT + DELETE", "Close all windows", "omarchy-hyprland-window-close-all")

-- Window movement

hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + H")
hl.unbind("SUPER + L")
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + backslash")


o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- o.bind("SUPER + grave", "Omarchy menu", "omarchy-menu toggle")
o.bind("SUPER + 0x0060", "Omarchy menu", "omarchy-menu toggle")

o.bind("SUPER + SLASH", "Everything", "omarchy-shell shell toggle b.everything")
o.bind("SUPER + F1", "App Launcher", "omarchy-shell shell toggle tyrsolution.app-launcher '{}'")
o.bind("SUPER + backslash", "Find everything . ","$HOME/.local/bin/omarchy-find")

-- o.bind("SUPER + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }))
-- o.bind("SUPER + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
-- o.bind("SUPER + UP", "Focus on above window", hl.dsp.focus({ direction = "u" }))
-- o.bind("SUPER + DOWN", "Focus on below window", hl.dsp.focus({ direction = "d" }))
--
-- o.bind("SUPER + SHIFT + ALT + LEFT", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
-- o.bind("SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
-- o.bind("SUPER + SHIFT + ALT + UP", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
-- o.bind("SUPER + SHIFT + ALT + DOWN", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))
--
-- o.bind("SUPER + SHIFT + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
-- o.bind("SUPER + SHIFT + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
-- o.bind("SUPER + SHIFT + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
-- o.bind("SUPER + SHIFT + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
--
-- o.bind("SUPER + ALT + LEFT", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
-- o.bind("SUPER + ALT + RIGHT", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
-- o.bind("SUPER + ALT + UP", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
-- o.bind("SUPER + ALT + DOWN", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))

-- Window sizing ussing `-` and `=`
--
-- o.bind("SUPER + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
-- o.bind("SUPER + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
-- o.bind("SUPER + SHIFT + code:20", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
-- o.bind("SUPER + SHIFT + code:21", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
-- o.bind("SUPER + ALT + code:20", "Expand window left a little", hl.dsp.window.resize({ x = -25, y = 0, relative = true }))
-- o.bind("SUPER + ALT + code:21", "Shrink window left a little", hl.dsp.window.resize({ x = 25, y = 0, relative = true }))
-- o.bind("SUPER + SHIFT + ALT + code:20", "Shrink window up a little", hl.dsp.window.resize({ x = 0, y = -25, relative = true }))
-- o.bind("SUPER + SHIFT + ALT + code:21", "Expand window down a little", hl.dsp.window.resize({ x = 0, y = 25, relative = true }))
-- o.bind("SUPER + CTRL + code:20", "Expand window left a lot", hl.dsp.window.resize({ x = -300, y = 0, relative = true }))
-- o.bind("SUPER + CTRL + code:21", "Shrink window left a lot", hl.dsp.window.resize({ x = 300, y = 0, relative = true }))
-- o.bind("SUPER + CTRL + SHIFT + code:20", "Shrink window up a lot", hl.dsp.window.resize({ x = 0, y = -300, relative = true }))
-- o.bind("SUPER + CTRL + SHIFT + code:21", "Expand window down a lot", hl.dsp.window.resize({ x = 0, y = 300, relative = true }))


-- o.bind("SUPER + J", "Toggle window split", hl.dsp.layout("togglesplit"))
-- o.bind("SUPER + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
-- o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings")

-- o.bind("SUPER + P", "Pseudo window", hl.dsp.window.pseudo())
-- o.bind("SUPER + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
-- o.bind("SUPER + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- o.bind("SUPER + CTRL + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")
-- o.bind("SUPER + ALT + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
-- o.bind("SUPER + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
-- o.bind("SUPER + ALT + Home", "Save window width", "omarchy-hyprland-window-width save")
-- o.bind("SUPER + Home", "Restore window width", "omarchy-hyprland-window-width restore")

-- for workspace = 1, 10 do
--   local key = "code:" .. tostring(workspace + 9)
--   o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
--   o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
--   o.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
-- end
--
-- o.bind("SUPER + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
-- o.bind("SUPER + ALT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
-- o.bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
-- o.bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))

-- o.bind("ALT + TAB", "Focus on next window", hl.dsp.window.cycle_next())
-- o.bind("ALT + SHIFT + TAB", "Focus on previous window", hl.dsp.window.cycle_next({ next = false }))
-- o.bind("ALT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
-- o.bind("ALT + SHIFT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
--
-- o.bind("CTRL + ALT + TAB", "Focus on next monitor", hl.dsp.focus({ monitor = "+1" }))
-- o.bind("CTRL + ALT + SHIFT + TAB", "Focus on previous monitor", hl.dsp.focus({ monitor = "-1" }))
--
-- o.bind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
-- o.bind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))
--
-- o.bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
-- o.bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- o.bind("SUPER + G", "Toggle window grouping", hl.dsp.group.toggle())
-- o.bind("SUPER + ALT + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))

-- o.bind("SUPER + ALT + TAB", "Next window in group", hl.dsp.group.next())
-- o.bind("SUPER + ALT + SHIFT + TAB", "Previous window in group", hl.dsp.group.prev())
--
-- o.bind("SUPER + CTRL + LEFT", "Move grouped window focus left", hl.dsp.group.prev())
-- o.bind("SUPER + CTRL + RIGHT", "Move grouped window focus right", hl.dsp.group.next())
--
-- o.bind("SUPER + ALT + mouse_down", "Next window in group", hl.dsp.group.next())
-- o.bind("SUPER + ALT + mouse_up", "Previous window in group", hl.dsp.group.prev())
--
-- for index = 1, 5 do
--   o.bind("SUPER + ALT + code:" .. tostring(index + 9), "Switch to group window " .. index, hl.dsp.group.active({ index = index }))
-- end

-- o.bind("SUPER + SLASH", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up")
-- o.bind("SUPER + ALT + SLASH", "Monitor scaling down", "omarchy-hyprland-monitor-scaling down")


-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle")
-- o.bind("SUPER + ALT + SPACE", "Apps menu", "omarchy-menu toggle apps")
-- o.bind("SUPER + CTRL + E", "Emojis", "omarchy-shell shell toggle omarchy.emojis")
-- o.bind("SUPER + CTRL + C", "Capture menu", "omarchy-menu toggle capture")
-- o.bind("SUPER + CTRL + O", "Toggle menu", "omarchy-menu toggle toggle")
-- o.bind("SUPER + CTRL + H", "Hardware menu", "omarchy-menu toggle hardware")
-- o.bind("SUPER + SHIFT + code:201", "Omarchy menu", "omarchy-menu toggle root")
-- o.bind("SUPER + ESCAPE", "System menu", "omarchy-menu toggle system")
-- o.bind("XF86PowerOff", "Power menu", "omarchy-menu toggle system", { locked = true })
-- o.bind("SUPER + ALT + K", "Tmux keybindings", "omarchy-menu-tmux-keybindings")
-- o.bind("SUPER + CTRL + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")
-- o.bind("SUPER + CTRL + Q", "Calculator", "omacalc")
-- o.bind("XF86Calculator", "Calculator", "omacalc")
--
-- o.bind_toggle("SUPER + SHIFT + SPACE", "Toggle top bar", "bar")
-- o.bind("SUPER + CTRL + SPACE", "Background switcher", "omarchy-menu toggle background")
-- o.bind("SUPER + SHIFT + CTRL + SPACE", "Theme menu", "omarchy-menu toggle theme")
-- o.bind("SUPER + BACKSPACE", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")
-- o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", "omarchy-hyprland-window-gaps-toggle")
-- o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", "omarchy-hyprland-window-single-square-aspect-toggle")
--
-- -- xkbcommon names the comma keysym "comma"; the upper-case "COMMA" does not match.
-- o.bind("SUPER + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
-- o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
-- o.bind_toggle("SUPER + CTRL + comma", "Toggle silencing notifications", "notification-silencing")
-- o.bind("SUPER + ALT + comma", "Invoke last notification", "omarchy-shell notifications invokeLast")
-- o.bind("SUPER + SHIFT + ALT + comma", "Open notification history", "omarchy-shell notifications showHistory")
--
-- o.bind_toggle("SUPER + CTRL + I", "Toggle locking on idle", "idle")
-- o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
-- o.bind("SUPER + CTRL + Delete", "Toggle laptop display", "omarchy-hyprland-monitor-internal toggle")
-- o.bind("SUPER + CTRL + ALT + Delete", "Toggle laptop display mirroring", "omarchy-hyprland-monitor-internal-mirror toggle")
-- o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
-- o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })
--
-- o.bind("PRINT", "Screenshot", "omarchy-capture-screenshot")
-- o.bind("ALT + PRINT", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")
-- o.bind("SUPER + ALT + code:34", "Make webcam overlay smaller", "omarchy-capture-webcam-resize smaller")
-- o.bind("SUPER + ALT + code:35", "Make webcam overlay larger", "omarchy-capture-webcam-resize larger")
-- o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
-- o.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", "omarchy-capture-text")
--
-- -- Keyboard control for the slurp region picker (see omarchy-capture-region).
-- -- The binds live exactly as long as a selection layer is on screen (slurp
-- -- opens one per monitor), so they cannot leak or get stuck.
-- -- Unbinding by key would take a same-key binding out of the user's own config
-- -- with it, so each handle is kept and removed individually.
-- local selection_layers = 0
-- local selection_binds = {}
--
-- hl.on("layer.opened", function(layer)
--   if layer.namespace == "selection" then
--     selection_layers = selection_layers + 1
--     if selection_layers == 1 then
--       selection_binds = {
--         hl.bind("RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-window"), { description = "Capture highlighted window" }),
--         hl.bind("CTRL + RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-fullscreen"), { description = "Capture entire screen" }),
--         hl.bind("TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window next"), { description = "Select next window to capture" }),
--         hl.bind("CTRL + TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window prev"), { description = "Select previous window to capture" }),
--       }
--       for _, direction in ipairs({ "left", "right", "up", "down" }) do
--         table.insert(
--           selection_binds,
--           hl.bind(direction:upper(), hl.dsp.exec_cmd("omarchy-capture-region --select-window " .. direction), { description = "Select window to capture" })
--         )
--       end
--     end
--   end
-- end)
--
-- hl.on("layer.closed", function(layer)
--   if layer.namespace == "selection" and selection_layers > 0 then
--     selection_layers = selection_layers - 1
--     if selection_layers == 0 then
--       for _, keybind in ipairs(selection_binds) do
--         keybind:unbind()
--       end
--       selection_binds = {}
--     end
--   end
-- end)
--
-- o.bind("SUPER + CTRL + S", "Share", "omarchy-menu toggle share")
--
-- o.bind("SUPER + CTRL + PERIOD", "Transcode", "omarchy-transcode")
--
-- o.bind("SUPER + CTRL + R", "Set reminder", "omarchy-menu toggle reminder-set")
-- o.bind("SUPER + CTRL + ALT + R", "Show reminders", "omarchy-reminder show")
-- o.bind("SUPER + SHIFT + CTRL + R", "Clear reminders", "omarchy-reminder clear")
--
-- o.bind("SUPER + CTRL + ALT + T", "Show time", "omarchy-notification-time")
-- o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "omarchy-notification-battery")
-- o.bind("SUPER + CTRL + ALT + W", "Toggle weather", "omarchy-notification-weather")
--
-- o.bind("SUPER + SHIFT + CTRL + A", "Agent", "omarchy-agent --pick")
-- o.bind("SUPER + CTRL + A", "Audio", "omarchy-shell shell toggle omarchy.audio")
-- o.bind("SUPER + CTRL + B", "Bluetooth", "omarchy-shell shell toggle omarchy.bluetooth")
-- o.bind("SUPER + CTRL + D", "Display", "omarchy-shell shell toggle omarchy.monitor")
-- o.bind("SUPER + CTRL + ALT + D", "Calendar", "omarchy-shell shell toggle omarchy.clock")
-- o.bind("SUPER + CTRL + W", "Network", "omarchy-shell shell toggle omarchy.network")
-- o.bind("SUPER + CTRL + P", "Power", "omarchy-shell shell toggle omarchy.power")
-- o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })
--
-- -- The letters above name a panel; the numbers count them. 1 is the leftmost
-- -- panel in the bar's right section, and a widget with no panel of its own (the
-- -- tray) is not counted, so the number matches the icon a user would point at.
-- -- A bar with fewer panels than this leaves the tail of the range doing nothing.
-- for panel = 1, 9 do
--   o.bind(
--     "SUPER + CTRL + code:" .. tostring(panel + 9),
--     "Bar panel " .. panel,
--     "omarchy-shell -q shell togglePanelAt right " .. panel
--   )
-- end
--
-- o.bind("SUPER + CTRL + Z", "Zoom in", function()
--   local zoom = hl.get_config("cursor.zoom_factor") or 1
--   hl.config({ cursor = { zoom_factor = zoom + 1 } })
-- end)
--
-- o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
--   hl.config({ cursor = { zoom_factor = 1 } })
-- end)
--
-- o.bind("SUPER + CTRL + L", "Lock system", "omarchy-system-lock")


-- o.bind("SUPER + W", "Close window", hl.dsp.window.close())
-- o.bind("CTRL + ALT + DELETE", "Close all windows", "omarchy-hyprland-window-close-all")


o.bind("SUPER + SHIFT + T", nil, hl.dsp.global("maduki-tech.omado:quick-add"))
--
-- # 3. the Setup menu rows — copy the setup.applauncher.* block from
-- #    docs/omarchy-menu.jsonc into ~/.config/omarchy/extensions/omarchy-menu.jsonc
--
-- # 4. check it
-- omarchy plugin list | grep app-launcher
-- omarchy-shell shell toggle tyrsolution.app-launcher '{}'


-- LMB -> 272
-- RMB -> 273
-- MMB -> 274
o.bind("SUPER + F2", "Minimize window", hl.dsp.window.move({
  workspace = "special:omarchy-minimized",
  follow = false,
}))
