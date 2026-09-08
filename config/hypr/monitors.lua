-- https://wiki.hypr.land/configuring/core/monitors/

hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 'auto' })

if cfg.hostname == 'super' then
  hl.config({ misc = { vrr = 3 }, render = { cm_auto_hdr = 0 } })
  hl.monitor({
    output = 'DP-2',
    mode = '2560x1440@164.96',
    position = '0x0',
    scale = 1.0,
  })

  for i = 1, 5 do
    local is_default = true
    hl.workspace_rule({
      workspace = i .. '',
      monitor = 'DP-2',
      persistent = true,
      default = is_default and (i == 1),
      layout = 'dwindle',
    })
  end

  hl.monitor({
    output = 'DP-3',
    mode = '2560x1440@143.97',
    -- mode = '3840x2160@60.00',
    position = '2560x0',
    scale = 1.0,
  })

  for i = 6, 10 do
    local is_default = true
    hl.workspace_rule({
      workspace = i .. '',
      monitor = 'DP-3',
      persistent = true,
      default = is_default and (i == 6),
      layout = 'dwindle',
    })
  end
end
