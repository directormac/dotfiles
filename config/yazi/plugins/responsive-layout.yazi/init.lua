--- responsive-layout.yazi
--- Upstream: https://github.com/leduckhc/responsive-layout.yazi
--- Responsive layout adapting to narrow terminals with vertical stacking

--- @since 26.1.22

-- responsive-layout.yazi
--
-- Make Yazi's manager layout responsive to terminal width:
--   * Wide   (>= wide_min cols): parent + current + preview (the default 3 panes)
--   * Narrow (<  wide_min cols): current (top) + preview (bottom), stacked
--                                vertically with a horizontal divider
--
-- It reads the runtime ratio (rt.mgr.ratio) in wide mode, so it stays
-- compatible with the toggle-pane.yazi plugin.
--
-- NOTE: this overrides `Tab:layout` and `Tab:build`, so it can interact with
-- other UI plugins that also override `Tab` (e.g. full-border.yazi). Whichever
-- `setup()` runs last wins; call this one accordingly.

local function setup(self, opts)
	opts = opts or {}
	local WIDE_MIN = opts.wide_min or 90 -- >= this width → 3 panes; below → vertical stack
	local SPLIT = opts.split or 0.5      -- vertical top(current)/bottom(preview) fraction
	local DIVIDER = opts.divider or "─"  -- glyph used for the horizontal divider

	-- Read the *runtime* ratio so toggle-pane.yazi (which mutates rt.mgr.ratio)
	-- keeps working. Supports both the array form ({a,b,c}) the plugin sets and
	-- the struct form (.parent/.current/.preview).
	local function ratio()
		local r = rt.mgr.ratio
		return (r[1] or r.parent), (r[2] or r.current), (r[3] or r.preview)
	end

	-- One-row horizontal divider component for the stacked (vertical) layout.
	-- Must carry an `_id`, otherwise Yazi silently fails to redraw the region.
	local HDivider = { _id = "responsive-hdivider" }
	function HDivider:new(area) return setmetatable({ _area = area }, { __index = self }) end
	function HDivider:reflow() return { self } end
	function HDivider:redraw()
		return {
			ui.Bar(ui.Edge.TOP):area(self._area):symbol(DIVIDER):style(th.mgr.border_style),
		}
	end
	function HDivider:click(event, up) end
	function HDivider:scroll(event, step) end
	function HDivider:touch(event, step) end
	function HDivider:drag(event) end

	function Tab:layout()
		local w = self._area.w
		self._vertical = false

		if w >= WIDE_MIN then
			-- Honor the runtime ratio → toggle-pane min/max/reset all work here.
			local p, c, v = ratio()
			local all = p + c + v
			self._chunks = ui.Layout()
				:direction(ui.Layout.HORIZONTAL)
				:constraints({
					ui.Constraint.Ratio(p, all),
					ui.Constraint.Ratio(c, all),
					ui.Constraint.Ratio(v, all),
				})
				:split(self._area)
		else
			-- Narrow: stack current (top) + divider + preview (bottom) vertically.
			-- Compute rects manually (deterministic) rather than relying on Fill.
			self._vertical = true
			local a = self._area
			local top_h = math.floor((a.h - 1) * SPLIT)
			self._divider = ui.Rect { x = a.x, y = a.y + top_h, w = a.w, h = 1 }
			-- Tab:build() expects a 3-element {parent, current, preview}.
			-- Give parent a zero-size rect so it renders nothing.
			self._chunks = {
				ui.Rect { x = a.x, y = a.y, w = 0, h = 0 },
				ui.Rect { x = a.x, y = a.y, w = a.w, h = top_h },
				ui.Rect { x = a.x, y = a.y + top_h + 1, w = a.w, h = a.h - top_h - 1 },
			}
		end
	end

	function Tab:build()
		local c = self._chunks

		if self._vertical then
			-- Stacked mode: no Rails (that draws the stray vertical bar); add a
			-- horizontal divider between current and preview instead.
			self._children = {
				Current:new(c[2]:pad(ui.Pad.x(1)), self._tab),
				Preview:new(c[3]:pad(ui.Pad.x(1)), self._tab),
				HDivider:new(self._divider),
				Markers:new(c, self._tab),
			}
			return
		end

		-- Default horizontal build.
		local p = c[2].w > 0 and 0 or 1
		self._children = {
			Parent:new(c[1]:pad(ui.Pad(0, p, 0, 1)), self._tab),
			Current:new(c[2]:pad(ui.Pad.x(1)), self._tab),
			Preview:new(c[3]:pad(ui.Pad(0, 1, 0, p)), self._tab),
			Rails:new(c, self._tab),
			Markers:new(c, self._tab),
		}
	end
end

return { setup = setup }
