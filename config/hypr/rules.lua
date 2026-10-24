--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
  -- Ignore maximize requests from all apps (negative:steam so Steam maximize works,
  -- and disabled by default so client maximize buttons are respected)
  name = 'suppress-maximize-events',
  match = { class = 'negative:steam' },

  suppress_event = 'maximize',
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name = 'fix-xwayland-drags',
  match = {
    class = '^$',
    title = '^$',
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

-- Only inhibit idle when fullscreen (e.g. video playback in fullscreen),
-- allowing displays to idle/sleep when playing music or background audio in a window.
hl.window_rule({
  name = 'idle-inhibit-fullscreen-browsers',
  match = { class = '^(zen|zen-beta|firefox|chromium|google-chrome)$' },
  idle_inhibit = 'fullscreen',
})

hl.window_rule({
  name = 'idle-inhibit-fullscreen-media',
  match = { class = '^(mpv|vlc|vesktop|discord|steam)$' },
  idle_inhibit = 'fullscreen',
})

-- Apps launched floating and centered using their natural/intrinsic size
local floating_centered_apps = {
  'bitwarden',
  'feh',
  'gnome-disks',
  'gsmartcontrol',
  'com.danklinux.dankcalendar',
  'dev.duxlabs.calendar',
  'galculator',
  'org.pulseaudio.pavucontrol',
  'org.localsend.localsend_app',
  'mpv',
  'nm-connection-editor',
  'Waydroid',
  'com.jaoushingan.WaydroidHelper',
}

for _, app in ipairs(floating_centered_apps) do
  hl.window_rule({
    name = 'float-center-' .. app,
    match = { class = app },
    float = true,
    center = true,
  })
end

-- Apps launched floating, centered, and sized (50% width and height)
local floating_sized_apps = {
  'com.ghostty.float',
  'org.gnome.Nautilus',
  'dev.duxlabs.files',
  'dfiles',
  'com.neovim.editor',
  'com.superfile.fm',
  'virt-manager',
  'qemu',
}

for _, app in ipairs(floating_sized_apps) do
  hl.window_rule({
    name = 'float-sized-' .. app,
    match = { class = app },
    float = true,
    center = true,
    size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
  })
end

-------------------
------ GAMING ------
-------------------

hl.window_rule({
  name = 'gamescope-instance',
  match = { class = '^gamescope$' },
  fullscreen = true,
  immediate = true, -- Allow tearing for minimum input latency / direct scanout
  no_shortcuts_inhibit = false, -- Allow gamescope to capture and handle shortcut inhibition
  idle_inhibit = 'always', -- Inhibit display sleep while in-game
})

-- Auto-switch Hyprland to gamemode submap when a game window is focused
local is_gamemode_active = false

local function is_game_window(win)
  if not win or not win.class then return false end
  local c = win.class:lower()
  local t = (win.title or ''):lower()

  -- Steam Proton games (class is always "steam_app_<appid>")
  if c:match('^steam_app_') then return true end

  -- Gamescope
  if c == 'gamescope' then return true end

  -- Windows executables via Wine / Proton / Bottles / Lutris
  if c:match('%.exe$') or t:match('%.exe$') then return true end

  -- Known standalone native games & emulators
  local known_games = {
    ['cs2'] = true,
    ['dota2'] = true,
    ['hl2_linux'] = true,
    ['osu!'] = true,
    ['ryujinx'] = true,
    ['yuzu'] = true,
    ['rpcs3'] = true,
    ['dolphin-emu'] = true,
    ['retroarch'] = true,
    ['sober'] = true,
    ['wow.exe'] = true,
    ['wowclassic.exe'] = true,
  }
  if known_games[c] then return true end

  return false
end

hl.on('window.active', function(win)
  local game = is_game_window(win)
  if game and not is_gamemode_active then
    is_gamemode_active = true
    hl.dispatch(hl.dsp.submap('gamemode'))
    hl.exec_cmd("hyprctl notify 5 2000 'rgb(a6e3a1)' 'Game active: bindings isolated'")
    hl.exec_cmd('dms ipc call notifications enableDoNotDisturbIndefinitely')
  elseif not game and is_gamemode_active then
    is_gamemode_active = false
    hl.dispatch(hl.dsp.submap('reset'))
    hl.exec_cmd("hyprctl notify 1 2000 'rgb(cba6f7)' 'Normal bindings restored'")
    hl.exec_cmd('dms ipc call notifications disableDoNotDisturb')
  end
end)

-- 1. Main Steam application window launches maximized
hl.window_rule({
  name = 'steam-main-maximized',
  match = {
    class = '^steam$',
    title = '^Steam$',
  },
  maximize = true,
})

-- 2. Steam secondary windows (Sign in, Friends List, Settings, Chat, etc.)
-- launch floating with natural size and placement (not 50% width/height, not forced center)
hl.window_rule({
  name = 'steam-secondary-floating',
  match = {
    class = '^steam$',
    title = 'negative:^Steam$',
  },
  float = true,
  persistent_size = true,
})

hl.window_rule({
  match = {
    initial_title = 'Select what to share',
  },
  float = true,
  center = true,
  size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
})

hl.window_rule({
  match = {
    -- Matches contacts, calculators, and any app starting with waydroid.com
    class = [[waydroid\.com\..*]],
    -- Optional: If some apps have an empty class initially, you can catch them here too
    initial_class = [[waydroid\.com\..*]],
  },
  float = true,
  center = true,
  size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
})

hl.window_rule({
  match = { class = '(pinentry-)(.*)' },
  stay_focused = true,
  float = true,
})

-- hl.on('window.open', function(w)
--   if w.class == 'virt-manager' then
--     hl.dispatch(hl.dsp.window.move({
--       workspace = 5,
--       window = w,
--       float = true,
--       -- center = true,
--       -- size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
--     }))
--   end
-- end)

hl.on('window.open', function(w)
  if w.class ~= 'firefox' then return end
  if w.initial_title ~= 'Mozilla Firefox' then return end

  local ff_windows = hl.get_windows({ class = 'firefox' })
  if #ff_windows <= 1 then return end

  hl.dispatch(hl.dsp.window.float({ action = 'set', window = w }))

  local sub
  sub = hl.on('window.title', function(tw)
    if tw.address ~= w.address then return end
    if
      tw.title == ''
      or tw.title == 'Mozilla Firefox'
      or tw.title == 'about:blank'
      or tw.title:match('^about:.*Mozilla Firefox$')
    then
      return
    end

    sub:remove()

    if tw.title:match('^Extension:') then
      hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
      hl.dispatch(hl.dsp.window.center({ window = tw }))
      hl.dispatch(hl.dsp.focus({ window = tw }))
    else
      hl.dispatch(hl.dsp.window.float({ action = 'unset', window = tw }))
    end
  end)
end)
hl.on('window.open', function(w)
  if w.class ~= 'steam' then return end

  local function maximize_if_main(win)
    if win.title == 'Steam' or win.initial_title == 'Steam' then
      hl.dispatch(hl.dsp.window.fullscreen({ mode = 'maximized', window = win }))
      return true
    end
    return false
  end

  if maximize_if_main(w) then return end

  local sub
  sub = hl.on('window.title', function(tw)
    if tw.address ~= w.address then return end
    if tw.title == 'Steam' then
      sub:remove()
      hl.dispatch(hl.dsp.window.fullscreen({ mode = 'maximized', window = tw }))
    end
  end)
end)

hl.on('window.open', function(w)
  if w.class ~= 'zen' then return end
  if w.initial_title ~= 'Zen Browser' then return end

  local ff_windows = hl.get_windows({ class = 'zen' })
  if #ff_windows <= 1 then return end

  hl.dispatch(hl.dsp.window.float({ action = 'set', window = w }))

  local sub
  sub = hl.on('window.title', function(tw)
    if tw.address ~= w.address then return end
    if
      tw.title == ''
      or tw.title == 'Zen Browser'
      or tw.title == 'about:blank'
      or tw.title:match('^about:.*Zen Browser$')
      -- or tw.title:match('^about:.*Mozilla Firefox$')
    then
      return
    end

    sub:remove()

    if tw.title:match('^Extension:') then
      hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
      hl.dispatch(hl.dsp.window.center({ window = tw }))
      hl.dispatch(hl.dsp.focus({ window = tw }))
    else
      hl.dispatch(hl.dsp.window.float({ action = 'unset', window = tw }))
    end
  end)
end)

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
-- hl.window_rule({
-- 	name = "move-hyprland-run",
-- 	match = { class = "hyprland-run" },
--
-- 	move = "20 monitor_h-120",
-- 	float = true,
-- })

-- package.path = package.path .. ';./?.lua;./?/init.lua'
-- local smw = require('plugins.split-monitor-workspaces')
--
-- smw.setup({
--   workspace_count = 5, -- This will create 5 persistent workspaces on each monitor at startup
-- })

-- hl.on('window.open', function(w)
--   if w.class ~= 'zen' then return end
--   if w.initial_title ~= 'Zen Browser' then return end
--
--   local ff_windows = hl.get_windows({ class = 'zen' })
--   if #ff_windows <= 1 then return end
--
--   hl.dispatch(hl.dsp.window.float({ action = 'set', window = w }))
--
--   local sub
--   sub = hl.on('window.title', function(tw)
--     if tw.address ~= w.address then return end
--     if
--       tw.title == ''
--       or tw.title == 'Zen Browser'
--       or tw.title == 'about:blank'
--       or tw.title:match('^about:.*Zen Browser$')
--       -- or tw.title:match('^about:.*Mozilla Firefox$')
--     then
--       return
--     end
--
--     sub:remove()
--
--     if tw.title:match('^Extension:') then
--       hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
--       hl.dispatch(hl.dsp.window.center({ window = tw }))
--       hl.dispatch(hl.dsp.focus({ window = tw }))
--     else
--       hl.dispatch(hl.dsp.window.float({ action = 'unset', window = tw }))
--     end
--   end)
-- end)

-- if [ "$1" == "-f" ]; then
--   shift # remove the -f from the arguments
--   ghostty --class="ghostty.float" --window-width=120 --window-height=35 "$@"
-- elif [ "$1" == "-F" ]; then
--   shift
--   ghostty --class="ghostty.fullscreen" --fullscreen=true "$@"
-- else
--   ghostty "$@"
-- fi
