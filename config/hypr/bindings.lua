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
local fileManager = apps.fileManager
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
hl.bind(modkey .. ' + R', hl.dsp.window.float())

-- hl.bind(modkey .. ' + F', hl.dsp.window.fullscreen({ mode = 'maximized' }))
-- hl.bind(modkey .. ' + SHIFT + F', hl.dsp.window.fullscreen({ mode = 'fullscreen' }))

hl.bind(modkey .. ' + CTRL + F', hl.dsp.window.fullscreen({ mode = 'maximized', action = 'set' }))
hl.bind(modkey .. ' + F', hl.dsp.window.fullscreen({ mode = 'maximized', action = 'toggle' }))
hl.bind(modkey .. ' + SHIFT + F', hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'toggle' }))

hl.bind(
  modkey .. ' + SPACE',
  function()
    hl.dispatch(hl.dsp.window.cycle_next({
      floating = not hl.get_active_window().floating,
    }))
  end,
  { description = 'Switch focus between tiled and floating windows' }
)

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

--- Applications

-- Essential application bindings.
hl.bind(modkey .. ' + RETURN', hl.dsp.exec_cmd(terminal))
hl.bind(modkey .. ' + SHIFT + RETURN', hl.dsp.exec_cmd(terminal, cfg.floating_centered_wr))
hl.bind(modkey .. ' + E', hl.dsp.exec_cmd(fileManager, cfg.floating_centered_wr))
hl.bind(modkey .. ' + O', hl.dsp.exec_cmd(browser))
hl.bind(modkey .. ' + D', hl.dsp.exec_cmd('which-key'))
hl.bind(modkey .. ' + SPACE', hl.dsp.exec_cmd('dms ipc call spotlight toggle'))

hl.bind(modkey .. ' + SHIFT + Escape', hl.dsp.exec_cmd('dms ipc powermenu toggle'))

-- === Screenshots ===
hl.bind('Print', hl.dsp.exec_cmd('dms screenshot'))
hl.bind('CTRL + Print', hl.dsp.exec_cmd('dms screenshot full'))
hl.bind('ALT + Print', hl.dsp.exec_cmd('dms screenshot window'))

-- === Display Profiles ===
-- hl.bind('SUPER + P', hl.dsp.exec_cmd('dms ipc outputs cycleProfile'))

-- === System Controls ===
-- hl.bind('SUPER + SHIFT + P', hl.dsp.dpms({ action = 'toggle' }))

-- -- === Application Launchers ===
-- hl.bind('SUPER + T', hl.dsp.exec_cmd('ghostty'))
-- hl.bind('SUPER + space', hl.dsp.exec_cmd('dms ipc call spotlight toggle'))
-- hl.bind('ALT + space', hl.dsp.exec_cmd('dms ipc call spotlight-bar toggle'))
-- hl.bind('SUPER + V', hl.dsp.exec_cmd('dms ipc call clipboard toggle'))
-- hl.bind('SUPER + M', hl.dsp.exec_cmd('dms ipc call processlist focusOrToggle'))
-- hl.bind('SUPER + comma', hl.dsp.exec_cmd('dms ipc call settings focusOrToggle'))
-- hl.bind('SUPER + N', hl.dsp.exec_cmd('dms ipc call notifications toggle'))
-- hl.bind('SUPER + SHIFT + N', hl.dsp.exec_cmd('dms ipc call notepad toggle'))
-- hl.bind('SUPER + Y', hl.dsp.exec_cmd('dms ipc call dash toggle wallpaper'))
-- hl.bind('SUPER + TAB', hl.dsp.exec_cmd('dms ipc call hypr toggleOverview'))
-- hl.bind('SUPER + O', hl.dsp.exec_cmd('dms ipc call hypr toggleOverview'))
-- hl.bind('SUPER + X', hl.dsp.exec_cmd('dms ipc call powermenu toggle'))
--
-- -- === Cheat sheet
-- hl.bind('SUPER + SHIFT + Slash', hl.dsp.exec_cmd('dms ipc call keybinds toggle hyprland'))
--
-- -- === Security ===
-- hl.bind('SUPER + ALT + L', hl.dsp.exec_cmd('dms ipc call lock lock'))
-- hl.bind('SUPER + SHIFT + E', hl.dsp.exit())
-- hl.bind('CTRL + ALT + Delete', hl.dsp.exec_cmd('dms ipc call processlist focusOrToggle'))

-- hl.bind(
--   modkey .. ' + M',
--   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
-- )

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
