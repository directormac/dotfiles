--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name = 'suppress-maximize-events',
  match = { class = '.*' },

  suppress_event = 'maximize',
})
-- suppressMaximizeRule:set_enabled(false)

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

hl.window_rule({
  match = { class = '(pinentry-)(.*)' },
  stay_focused = true,
})

hl.window_rule({
  name = 'float-virt-manager',
  match = {
    class = 'virt-manager',
  },
  float = true,
  center = true,
  size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
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
