-- Originally from BalaLib by Toeler (https://github.com/Toeler/Balatro-HandPreview/blob/main/Mods/BalaLib/BalaLib.lua) used under GPLv3
-- Modified for use in Ankh by MathIsFun0 (https://github.com/MathIsFun0/Ankh)
-- Further modified for use in SystemClock

local MoveableContainer = UIBox:extend()
function MoveableContainer:init(args)
	args.definition = {
		n = G.UIT.ROOT,
		config = { colour = G.C.CLEAR },
		nodes = { {
			n = G.UIT.R,
			nodes = args.nodes or {}
		} }
	}

	UIBox.init(self, args)

	self.zoom = args.zoom or args.config.zoom
	if self.zoom then
		self.UIRoot:set_zoom(true, true, true)
	end

	self.attention_text = 'MoveableContainer'

	if args.config.instance_type then
		table.insert(G.I[args.config.instance_type], self)
	else
		table.insert(G.I.UIBOX, self)
	end
end

function Moveable:set_zoom(state, recursive, force)
	if self.zoom == state and not force then return end

	self.zoom = state
	if self.config.object then self.config.object.zoom = state end

	if recursive and self.children then
		for k, v in pairs(self.children) do
			v:set_zoom(state, true, force)
		end
	end
end

function Moveable:set_hover_state(state, recursive, force)
	if self.states.hover.is == state and not force then return end

	self.states.hover.is = state
	if self.config.object then self.config.object.states.hover.is = state end

	if recursive and self.children then
		for k, v in pairs(self.children) do
			v:set_hover_state(state, true, force)
		end
	end
end

function Moveable:set_drag_state(state, recursive, force)
	if self.states.drag.is == state and not force then return end

	self.states.drag.is = state
	if self.config.object then self.config.object.states.drag.is = state end

	if recursive and self.children then
		for k, v in pairs(self.children) do
			v:set_drag_state(state, true, force)
		end
	end
end

function MoveableContainer:hover()
	if self.states.drag.can then
		self:juice_up(0.05, 0.02)
		play_sound('chips1', math.random() * 0.1 + 0.55, 0.15)
		if self.zoom then
			self.UIRoot:set_hover_state(true, true)
		end
	end

	UIBox.hover(self)
end

function MoveableContainer:stop_hover()
	if self.zoom then
		self.UIRoot:set_hover_state(false, true)
	end
	UIBox.stop_hover(self)
end

function MoveableContainer:drag()
	if self.zoom then
		self.UIRoot:set_drag_state(true, true)
	end
	UIBox.drag(self)
end

function MoveableContainer:stop_drag()
	if self.zoom then
		self.UIRoot:set_drag_state(false, true)
	end
	UIBox.stop_drag(self)
end

return MoveableContainer