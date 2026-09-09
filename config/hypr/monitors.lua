-- https://wiki.hypr.land/configuring/core/monitors/

hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 'auto' })

--- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/#rules

local workspaces = {
  { id = '1', default_name = '一', is_default = true, persistent = true },
  { id = '2', default_name = '二', on_created_empty = '[maximize] ghostty' },
  { id = '3', default_name = '三', layout = 'scrolling' },
  { id = '4', default_name = '四', on_created_empty = 'dms ipc call spotlight toggle' },
  { id = '5', default_name = '五' },
  { id = '6', default_name = '六', is_default = true, persistent = true },
  { id = '7', default_name = '七' },
  { id = '8', default_name = '八' },
  { id = '9', default_name = '九' },
  { id = '10', default_name = '十' },
}

if cfg.hostname == 'super' then
  -- "urgent": "",
  -- "focused": "",
  -- "default": ""

  hl.config({ misc = { vrr = 3 }, render = { cm_auto_hdr = 0 } })

  hl.monitor({
    output = 'DP-2',
    mode = '2560x1440@164.96',
    position = '0x0',
    scale = 1.0,
  })

  hl.monitor({
    output = 'DP-3',
    mode = '2560x1440@143.97',
    -- mode = '3840x2160@60.00',
    position = '2560x0',
    scale = 1.0,
  })

  for i, ws in ipairs(workspaces) do
    -- Lua 1-indexed math: 1,2,3,4,5 go to DP-2. 6,7,8,9,10 go to DP-3.
    local monitor_target = (i <= 5) and 'DP-2' or 'DP-3'

    hl.workspace_rule({
      workspace = ws.id,
      default_name = ws.default_name,
      on_created_empty = ws.on_created_empty or '',
      monitor = monitor_target,
      persistent = ws.persistent or false,
      default = ws.is_default or false,
      layout = ws.layout or 'dwindle',
    })
  end
else
  for i, ws in ipairs(workspaces) do
    hl.workspace_rule({
      workspace = ws.id,
      default_name = ws.default_name,
      on_created_empty = ws.on_created_empty or '',
      persistent = ws.persistent or false,
      default = (i == 1),
      layout = ws.layout or 'dwindle',
    })
  end
end
