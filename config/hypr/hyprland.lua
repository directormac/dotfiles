-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

-- https://wiki.hypr.land/configuring/code-snippets/

require('config')

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env('XCURSOR_SIZE', '24')
hl.env('HYPRCURSOR_SIZE', '24')
hl.env('QT_QPA_PLATFORMTHEME', 'qt6ct')
hl.env('XDG_MENU_PREFIX', 'hyprland-')
if cfg.hostname == 'super' then
  -- https://wiki.hypr.land/configuring/extra/multi-gpu/
  hl.env('AQ_DRM_DEVICES', '/dev/dri/card2:/dev/dri/card1')
end

-- Set programs that you use
local apps = cfg.applications

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--

hl.on('hyprland.start', function()
  hl.exec_cmd('dbus-update-activation-environment --systemd --all')
  hl.exec_cmd('systemctl --user start hyprland-session.target')
  hl.exec_cmd('dms run')
  -- hl.exec_cmd('waybar -c ~/.config/waybar/config-hypr.jsonc')
  -- hl.exec_cmd('hyprpaper & hyprpm reload -n')
  hl.exec_cmd(apps.terminal, cfg.floating_centered_wr)
  hl.exec_cmd(apps.browser, {
    float = false,
    tile = true,
  })
end)

-------------------------------
---- IMPORT MODULES ----
-------------------------------

require('monitors')
require('bindings')
require('lookandfeel')
require('rules')

-- DMS Include Configs
require('dms.binds')
require('dms.binds-user')
require('dms.layout')
require('dms.windowrules')
require('dms.outputs')
