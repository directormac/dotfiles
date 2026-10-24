---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout = 'us',
    kb_variant = '',
    kb_model = '',
    kb_options = 'caps:hyper',
    kb_rules = '',

    follow_mouse = 1,
    numlock_by_default = true,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = 'horizontal',
  action = 'workspace',
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
-- 	name = "epic-mouse-v1",
-- 	sensitivity = -0.5,
-- })

---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- See https://wiki.hypr.land/configuring/core/binds/submaps/
-- See https://wiki.hypr.land/configuring/core/dispatchers/

local apps = cfg.applications

local terminal = apps.terminal
local fileManager = apps.fileManager or 'dfiles open'
-- local menu = apps.menu
local browser = apps.browser

local Utils = require('utils')

-- local modkey = 'SUPER' -- Sets "Windows" key as main modifier

---- Workspace Management

-- Switch workspaces with modkey + [0-9]
-- Move active window to a workspace with modkey + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(modkey .. ' + ' .. key, hl.dsp.focus({ workspace = i }), {
    desc = 'Move to workspace' .. key,
  })
  hl.bind(modkey .. ' + SHIFT + ' .. key, hl.dsp.window.move({ workspace = i }), {
    desc = 'Move window to ' .. '[' .. key .. ']' .. 'workspace.',
  })
end

-- Example special workspace (scratchpad)
hl.bind(modkey .. ' + S', hl.dsp.workspace.toggle_special('scratchpad'), {
  desc = 'Toogle scratchpad workspace.',
})

hl.bind(modkey .. ' + U', hl.dsp.focus({ urgent_or_last = true }), {
  desc = 'Focus urgent',
})

hl.bind(modkey .. ' + SHIFT + S', hl.dsp.window.move({ workspace = 'special:scratchpad' }), {
  desc = 'Move window to scratchpad workspace',
})

---- Window Management
local closeWindowBind = hl.bind(modkey .. ' + Q', hl.dsp.window.close())

closeWindowBind:set_enabled(false)

-- hl.bind(modkey .. ' + ALT + Q', closeWindowBind:set_enabled(true))
hl.bind(modkey .. ' + SHIFT + Q', hl.dsp.window.close())
hl.bind(modkey .. ' + C', hl.dsp.window.center())
hl.bind(modkey .. ' + P', hl.dsp.window.pseudo())

hl.bind(modkey .. '+ SHIFT + Space', hl.dsp.window.float())

hl.bind(
  modkey .. '+ CTRL+ Space',
  function()
    hl.dispatch(hl.dsp.window.cycle_next({
      floating = not hl.get_active_window().floating,
    }))
  end,
  { description = 'Switch focus between tiled and floating windows' }
)

hl.bind(modkey .. ' + CTRL + F', function(w)
  local win = hl.get_active_window()

  if not win then return end

  if win.fullscreen_client == 2 then
    -- Turn off tiled fullscreen (switch back to 0)
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0 }))
  else
    -- Turn on tiled fullscreen (switch to 2)
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
  end
end)

hl.bind(modkey .. ' + F', hl.dsp.window.fullscreen({ mode = 'maximized', action = 'toggle' }))

hl.bind(modkey .. ' + SHIFT + F', hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'toggle' }))

-- Scroll through existing workspaces with modkey + scroll
hl.bind(modkey .. ' + mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind(modkey .. ' + mouse_up', hl.dsp.focus({ workspace = 'e-1' }))

-- Move/resize windows with modkey + LMB/RMB and dragging
hl.bind(modkey .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(modkey .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

hl.bind(
  modkey .. ' + equal',
  Utils.layout.match({
    default = Utils.window.resize({ x = '5%', y = 0, relative = true }),
    scrolling = hl.dsp.layout('colresize +conf'),
  }),
  { repeating = true }
)
hl.bind(
  modkey .. ' + minus',
  Utils.layout.match({
    default = Utils.window.resize({ x = '-5%', y = 0, relative = true }),
    scrolling = hl.dsp.layout('colresize -conf'),
  }),
  { repeating = true }
)
hl.bind(modkey .. ' + SHIFT + equal', Utils.window.resize({ x = 0, y = '5%', relative = true }), { repeating = true })
hl.bind(modkey .. ' + SHIFT + minus', Utils.window.resize({ x = 0, y = '-5%', relative = true }), { repeating = true })

local hjkl_binds = {
  { key = 'H', direction = 'left' },
  { key = 'J', direction = 'down' },
  { key = 'K', direction = 'up' },
  { key = 'L', direction = 'right' },
}

for _, bind in ipairs(hjkl_binds) do
  hl.bind(modkey .. ' + ' .. bind.key, hl.dsp.focus({ direction = bind.direction }))
  hl.bind(modkey .. ' + SHIFT + ' .. bind.key, hl.dsp.window.move({ direction = bind.direction }))
  hl.bind(
    modkey .. ' + CTRL + ' .. bind.key,
    Utils.layout.match({
      dwindle = hl.dsp.window.swap({ direction = bind.direction }),
      scrolling = function()
        local fn

        if bind.direction == 'left' or bind.direction == 'right' then
          fn = hl.dsp.layout('swapcol ' .. (bind.direction == 'left' and 'l' or 'r'))
        else
          fn = hl.dsp.window.swap({ direction = bind.direction })
        end

        hl.dispatch(fn)
      end,
    })
  )
end

hl.bind(modkey .. ' + SHIFT + equal', Utils.window.resize({ x = 0, y = '5%', relative = true }), { repeating = true })
hl.bind(modkey .. ' + SHIFT + minus', Utils.window.resize({ x = 0, y = '-5%', relative = true }), { repeating = true })

---- Group Management

-- hl.bind(modkey .. ' + W', hl.dsp.group.toggle())
-- hl.bind(modkey .. ' + BracketLeft', hl.dsp.group.prev())
-- hl.bind(modkey .. ' + BracketRight', hl.dsp.group.next())

---- Layout Management

hl.bind(modkey .. ' + R', hl.dsp.layout('togglesplit'))
hl.bind(modkey .. ' + Backslash', Utils.layout.next())
hl.bind(modkey .. ' + SHIFT + Backslash', Utils.layout.prev())

---- Screen Capture

-- hl.bind(modkey .. ' + P', Utils.screenshot.region())
-- hl.bind(modkey .. ' + SHIFT + P', Utils.screenshot.window())
-- hl.bind(modkey .. ' + CTRL + P', Utils.screenshot.screen())

---- Cursor (wl-kbptr / wlrctl)
-- https://github.com/moverest/wl-kbptr#hyprland
-- See https://wiki.hypr.land/configuring/core/binds/submaps/

-- Keep the cursor visible while it is being driven from the keyboard.
local function cursor_kb_mode(enabled)
  hl.config({
    cursor = {
      inactive_timeout = enabled and 0 or 3,
      hide_on_key_press = not enabled,
    },
  })
end

hl.bind(modkey .. ' + G', function()
  cursor_kb_mode(true)
  hl.dispatch(hl.dsp.submap('cursor'))
end, { description = 'Enter the cursor submap' })

hl.define_submap('cursor', function()
  -- Jump the cursor to a position. wl-kbptr grabs the keyboard, so drop out of
  -- the submap while it runs and re-enter once it has finished.
  hl.bind('q', function()
    hl.dispatch(hl.dsp.submap('reset'))
    hl.exec_cmd('wl-kbptr')
  end, { description = 'Jump cursor to a position' })

  -- Floating mode with OpenCV auto-detection: wl-kbptr screen-captures the
  -- output, highlights detected clickable elements, then left-clicks the one
  -- you pick. Requires the binary to be built with the opencv feature.
  hl.bind('a', function()
    hl.dispatch(hl.dsp.submap('reset'))
    hl.exec_cmd('wl-kbptr -o modes=floating,click -o mode_floating.source=detect')
  end, { description = 'Click a detected element' })

  -- Movement
  hl.bind('j', hl.dsp.exec_cmd('wlrctl pointer move 0 10'), { repeating = true })
  hl.bind('k', hl.dsp.exec_cmd('wlrctl pointer move 0 -10'), { repeating = true })
  hl.bind('l', hl.dsp.exec_cmd('wlrctl pointer move 10 0'), { repeating = true })
  hl.bind('h', hl.dsp.exec_cmd('wlrctl pointer move -10 0'), { repeating = true })

  -- Buttons
  hl.bind('v', hl.dsp.exec_cmd('wlrctl pointer click left'), { description = 'Left click' })
  hl.bind('b', hl.dsp.exec_cmd('wlrctl pointer click middle'), { description = 'Middle click' })
  hl.bind('n', hl.dsp.exec_cmd('wlrctl pointer click right'), { description = 'Right click' })

  -- Scroll up / down
  hl.bind('e', hl.dsp.exec_cmd('wlrctl pointer scroll 10 0'), { repeating = true })
  hl.bind('r', hl.dsp.exec_cmd('wlrctl pointer scroll -10 0'), { repeating = true })

  -- Scroll left / right
  hl.bind('t', hl.dsp.exec_cmd('wlrctl pointer scroll 0 -10'), { repeating = true })
  hl.bind('g', hl.dsp.exec_cmd('wlrctl pointer scroll 0 10'), { repeating = true })

  -- Exit
  hl.bind('escape', function()
    cursor_kb_mode(false)
    hl.dispatch(hl.dsp.submap('reset'))
  end, { description = 'Exit the cursor submap' })
end)

-- Toggle Gamemode / Passthrough manually
hl.bind(modkey .. ' + F1', hl.dsp.submap('gamemode'), { desc = 'Enter gamemode (disable Hyprland bindings)' })

hl.define_submap('gamemode', function()
  -- Only the escape key is intercepted by Hyprland; everything else passes to the game
  hl.bind(modkey .. ' + F1', hl.dsp.submap('reset'), { desc = 'Exit gamemode' })

  -- Optional: keep media volume keys functional during gameplay if desired
  -- hl.bind('', 'XF86AudioRaiseVolume', hl.dsp.exec_cmd('dms ipc call audio increment'))
  -- hl.bind('', 'XF86AudioLowerVolume', hl.dsp.exec_cmd('dms ipc call audio decrement'))
end)

--- Applications

-- Essential application bindings.
hl.bind(modkey .. ' + RETURN', hl.dsp.exec_cmd('ghostty +new-window'))
hl.bind(modkey .. ' + SHIFT + RETURN', hl.dsp.exec_cmd('ghostty --class=com.ghostty.float', cfg.floating_centered_wr))

-- Quake-style kitty quick access terminal (see ~/.config/kitty/quick-access-terminal.conf)
-- hl.bind(modkey .. ' + grave', hl.dsp.exec_cmd('kitty +kitten quick-access-terminal'), {
--   desc = 'Toggle kitty quick access terminal',
-- })

hl.bind(modkey .. ' + E', hl.dsp.exec_cmd(fileManager))
hl.bind(modkey .. ' + O', hl.dsp.exec_cmd(browser))
hl.bind('CTRL + ALT + comma', hl.dsp.exec_cmd('pavucontrol'))
hl.bind('CTRL + ALT + m', hl.dsp.exec_cmd('ghostty --class=com.ghostty.float -e rmpc'))
hl.bind(modkey .. ' + D', hl.dsp.exec_cmd('which-key'))
hl.bind(modkey .. ' + SPACE', hl.dsp.exec_cmd('dms ipc call spotlight toggle'))

-- Voice Dictation (Voxtype) & Transcription (Voxterm)
hl.bind(modkey .. ' + V', hl.dsp.exec_cmd('voxtype record toggle'), { desc = 'Toggle voice dictation' })
hl.bind(
  modkey .. ' + SHIFT + V',
  hl.dsp.exec_cmd('ghostty --class=com.ghostty.float -e voxterm', cfg.floating_centered_wr),
  { desc = 'Voice transcription TUI' }
)
hl.bind(modkey .. ' + ALT + V', hl.dsp.exec_cmd('voxtype record cancel'), { desc = 'Cancel voice dictation' })
hl.bind(modkey .. ' + Escape', hl.dsp.exec_cmd('dms ipc call hypr toggleOverview'))

-- https://duxlabs.dev/docs/dms/compositors
hl.bind(
  modkey .. ' + SHIFT + SLASH',
  hl.dsp.exec_cmd('dms ipc call keybinds toggle hyprland'),
  { desc = 'DMS Keybinds Cheatsheet' }
)
hl.bind(modkey .. ' + SHIFT + Escape', hl.dsp.exec_cmd('dms ipc call powermenu toggle'), { desc = 'DMS Powermenu' })
hl.bind(modkey .. ' + X', hl.dsp.exec_cmd('dms ipc call powermenu toggle'), { desc = 'DMS Powermenu' })

-- === DMS Quick Capture & Screenshots ===
hl.bind(
  'Print',
  hl.dsp.exec_cmd('dms ipc call quickCapture screenshot region copy'),
  { desc = 'Screenshot region to clipboard' }
)
hl.bind(
  'CTRL + Print',
  hl.dsp.exec_cmd('dms ipc call quickCapture screenshot full copy'),
  { desc = 'Screenshot fullscreen to clipboard' }
)
hl.bind(
  'ALT + Print',
  hl.dsp.exec_cmd('dms ipc call quickCapture screenshot window copy'),
  { desc = 'Screenshot window to clipboard' }
)
hl.bind(
  'SHIFT + Print',
  hl.dsp.exec_cmd('dms ipc call quickCapture screenshot region edit'),
  { desc = 'Screenshot region to editor' }
)
hl.bind(modkey .. ' + Print', hl.dsp.exec_cmd('dms ipc call quickCapture menu'), { desc = 'DMS Quick Capture Menu' })
hl.bind(
  modkey .. ' + SHIFT + C',
  hl.dsp.exec_cmd('dms ipc call quickCapture menu'),
  { desc = 'DMS Quick Capture Menu' }
)

-- === DMS Clipboard & History ===
hl.bind(modkey .. ' + CTRL + V', hl.dsp.exec_cmd('dms ipc call clipboard toggle'), { desc = 'DMS Clipboard History' })
hl.bind(modkey .. ' + B', hl.dsp.exec_cmd('dms ipc call clipboard toggle'), { desc = 'DMS Clipboard History' })
hl.bind(
  modkey .. ' + SHIFT + B',
  hl.dsp.exec_cmd('sh -c "cliphist list | dms dmenu -p Clipboard: | cliphist decode | wl-copy"'),
  { desc = 'DMS dmenu Cliphist Picker' }
)

-- === DMS Notification Center & Notepad ===
hl.bind(modkey .. ' + N', hl.dsp.exec_cmd('dms ipc call notifications toggle'), { desc = 'DMS Notification Center' })
hl.bind(modkey .. ' + SHIFT + N', hl.dsp.exec_cmd('dms ipc call notepad toggle'), { desc = 'DMS Notepad' })

-- === DMS Color Picker ===
hl.bind(modkey .. ' + SHIFT + P', hl.dsp.exec_cmd('dms color pick -a'), { desc = 'DMS Eyedropper Color Picker' })
hl.bind(
  modkey .. ' + CTRL + C',
  hl.dsp.exec_cmd('dms ipc call color-picker toggle'),
  { desc = 'DMS Color Picker Modal' }
)

-- === DMS Dash & Settings ===
hl.bind(modkey .. ' + comma', hl.dsp.exec_cmd('dms ipc call settings focusOrToggle'), { desc = 'DMS Settings' })
hl.bind(modkey .. ' + M', hl.dsp.exec_cmd('dms ipc call processlist focusOrToggle'), { desc = 'DMS Task Manager' })
hl.bind('CTRL + ALT + Delete', hl.dsp.exec_cmd('dms ipc call processlist focusOrToggle'), { desc = 'DMS Task Manager' })
hl.bind(modkey .. ' + Y', hl.dsp.exec_cmd('dms ipc call dash toggle wallpaper'), { desc = 'DMS Wallpaper Browser' })
hl.bind(modkey .. ' + TAB', hl.dsp.exec_cmd('dms ipc call hypr toggleOverview'), { desc = 'DMS Window Overview' })
hl.bind(modkey .. ' + ALT + space', hl.dsp.exec_cmd('dms dmenu -p "Run:"'), { desc = 'DMS dmenu Command Runner' })

-- === Multimedia Controls ===
hl.bind(
  'XF86AudioRaiseVolume',
  hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioLowerVolume',
  hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioMute',
  hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioMicMute',
  hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),
  { locked = true, repeating = true }
)
-- Requires playerctl
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('playerctl previous'), { locked = true })
hl.bind('XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), { locked = true })

-- Skip player on long press and only skip 5s on normal press
hl.bind(modkey .. ' + XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), { long_press = true })
hl.bind(modkey .. '+ XF86AudioNext', hl.dsp.exec_cmd('playerctl position +5'))

-- === Display Profiles ===
-- hl.bind('SUPER + P', hl.dsp.exec_cmd('dms ipc outputs cycleProfile'))

hl.bind('SUPER + P', hl.dsp.window.pseudo(), {
  desc = 'Pseudo mode',
})

-- === Security ===
hl.bind('SUPER + ALT + L', hl.dsp.exec_cmd('dms ipc call lock lock'), { desc = 'DMS Lock Screen' })

-- o.bind("SUPER + P", "Pseudo window", hl.dsp.window.pseudo())
-- o.bind("SUPER + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "none" }))

-- hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- hl.bind('SUPER + ALT + F', hl.dsp.window.fullscreen({ mode = 'maximized' }))

-- hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- -- Laptop multimedia keys for volume and LCD brightness
-- hl.bind(
--   'XF86AudioRaiseVolume',
--   hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   'XF86AudioLowerVolume',
--   hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   'XF86AudioMute',
--   hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   'XF86AudioMicMute',
--   hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),
--   { locked = true, repeating = true }
-- )
-- hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%+'), { locked = true, repeating = true })
-- hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%-'), { locked = true, repeating = true })
--
-- -- Requires playerctl
-- hl.bind('XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), { locked = true })
-- hl.bind('XF86AudioPause', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
-- hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
-- hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('playerctl previous'), { locked = true })

-- hl.bind('SUPER + G', hl.dsp.submap('group_management'), { description = 'Enter a group management submap' })
--
-- local map = function(key, action, description)
--   hl.bind(key, function()
--     hl.dispatch(action)
--     hl.dispatch(hl.dsp.submap('reset'))
--   end, { description = description })
-- end

-- hl.define_submap("group_management", function()
--     map("g", hl.dsp.group.toggle(), "Toggle window group")
--
--     map("h", hl.dsp.window.move({ into_group = "l" }), "Move window into a group on the left")
--     map("j", hl.dsp.window.move({ into_group = "d" }), "Move window into a group on the bottom")
--     map("k", hl.dsp.window.move({ into_group = "u" }), "Move window into a group on the top")
--     map("l", hl.dsp.window.move({ into_group = "r" }), "Move window into a group on the right")
--
--     map("e", hl.dsp.window.move({ out_of_group = true }), "Move window out of group")
--
--     map("n", hl.dsp.group.next(), "Next window in group")
--     map("p", hl.dsp.group.prev(), "Previous window in group")
--
--     map("f", hl.dsp.group.move_window(), "Move window forward in the group order")
--     map("b", hl.dsp.group.move_window({ forward = false }), "Move window backward in the group order")
--
--     map("t", hl.dsp.group.lock_active(), "Toggle group lock")
--
--     for i = 1, 10 do
--         map(tostring(i % 10), hl.dsp.group.active({ index = i }), "Focus window " .. i .. " in a group")
--     end
--
--     hl.bind("escape", hl.dsp.submap("reset"), { description = "Quit submap" })
-- end)
