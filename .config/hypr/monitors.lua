-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Managed by im0001gt.screens (Screens bar panel).

local omarchy_gdk_scale = 1
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- BEGIN im0001gt.screens
hl.monitor({ output = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", mode = "2560x1440@164.96", position = "0x0", scale = 1.0, vrr = 3, 
  bitdepth = 10, supports_hdr = 1, cm = "hdredid", sdr_min_luminance = 0, sdr_max_luminance = 353, sdrbrightness = 1.25, sdr_eotf = "srgb", min_luminance = 0.01, 
  max_luminance = 409, max_avg_luminance = 409 })
hl.monitor({ output = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", mode = "2560x1440@143.97", position = "2560x0", scale = 1.0, vrr = 3, 
  bitdepth = 10, supports_hdr = 1, cm = "hdr", sdr_min_luminance = 0, sdr_max_luminance = 400, sdrbrightness = 1.25, sdr_eotf = "srgb", min_luminance = 0.05, 
  max_luminance = 418, max_avg_luminance = 418 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.config({ misc = { vrr = 3 }, render = { cm_auto_hdr = 0 } })
hl.workspace_rule({ workspace = "1", monitor = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "desc:LG Electronics LG ULTRAGEAR 308NTGY1D007", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", persistent = true, default = true })
hl.workspace_rule({ workspace = "7", monitor = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS AD27QD 19110B001090", persistent = true })
-- END im0001gt.screens
