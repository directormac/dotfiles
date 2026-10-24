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
--  hl.env('HYPRCURSOR_SIZE', '24')
hl.env('QT_QPA_PLATFORMTHEME', 'qt6ct')
hl.env('QT_QPA_PLATFORM', 'wayland')
hl.env('XDG_MENU_PREFIX', 'hyprland-')

-- https://wiki.hypr.land/configuring/extra/multi-gpu/
-- GPU configuration is guarded so VM testing or non-multi-GPU hosts don't crash Aquamarine
local function file_exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

if cfg.hostname == 'super' and file_exists('/dev/dri/card2') and file_exists('/dev/dri/card1') then
  hl.env('AQ_DRM_DEVICES', '/dev/dri/card2:/dev/dri/card1')
elseif not file_exists('/dev/dri/card2') then
  hl.env('WLR_NO_HARDWARE_CURSORS', '1')
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

local is_vm = os.getenv('HYPRLAND_IS_VM') == '1' or os.getenv('IS_VM') == '1'

hl.on('hyprland.start', function()
  hl.exec_cmd('dbus-update-activation-environment --systemd --all')
  -- Authorize root connections to Xwayland for elevated graphical utilities
  hl.exec_cmd('xhost +si:localuser:root')
  -- DMS is managed as a systemd user service (dms.service bound to graphical-session.target)
  -- Optional: Clipboard history
  hl.exec_cmd('sh -c "wl-clip-persist --clipboard regular --reconnect-tries 0 &"')
  hl.exec_cmd('sh -c "wl-paste --watch cliphist store &"')
  -- hl.exec_cmd('waybar -c ~/.config/waybar/config-hypr.jsonc')
  -- hl.exec_cmd('hyprpaper & hyprpm reload -n')
  hl.exec_cmd(apps.terminal, cfg.floating_centered_wr)
  hl.exec_cmd(apps.browser, {
    float = false,
    tile = true,
  })
  -- Pre-start the kitty quick access terminal hidden so the first SUPER+grave
  -- is instant (config: ~/.config/kitty/quick-access-terminal.conf).
  -- hl.exec_cmd('kitty +kitten quick-access-terminal --detach -o start_as_hidden=yes')
end)

-------------------------------
---- IMPORT MODULES ----
-------------------------------

require('monitors')
require('bindings')
require('lookandfeel')
require('rules')

-- DMS Include Configs (guarded for non-VM environments)
if not is_vm then
  require('dms.binds')
  require('dms.binds-user')
  require('dms.layout')
  require('dms.windowrules')
  require('dms.outputs')
  require('dms.cursor')
end
