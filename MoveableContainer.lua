-- Originally from BalaLib by Toeler (https://github.com/Toeler/Balatro-HandPreview/blob/main/Mods/BalaLib/BalaLib.lua) used under GPLv3
-- Modified for use in Ankh by MathIsFun0 (https://github.com/MathIsFun0/Ankh)
-- Further modified for use in SystemClock

MoveableContainer = UIBox:extend()
function MoveableContainer:init(args)
	args.definition = {
		n = G.UIT.ROOT,
		config = {
			align = 'tm',
			colour = G.C.CLEAR,
			scale = 1,
		},
		nodes = { {
			n = G.UIT.R,
			nodes = args.nodes or {}
		} },
	}

	UIBox.init(self, args)

	self.states.drag.can = true
	self.states.hover.can = true
	self.attention_text = 'MoveableContainer' -- Workaround so that this is drawn over other elements

	if args.config.instance_type then
		table.insert(G.I[args.config.instance_type], self)
	else
		table.insert(G.I.UIBOX, self)
	end
end

function Moveable:set_hover_state(state)
	self.zoom = true
	self.states.hover.is = state
	self.parrallax_dist = 1

	if self.config.object then
		self.config.object.zoom = true
		self.config.object.states.hover.is = state
	end

	if self.children then
		for k, v in pairs(self.children) do
			v:set_hover_state(state)
		end
	end
end

function Moveable:set_drag_state(state)
	self.zoom = true
	self.states.drag.is = state

	if self.config.object then
		self.config.object.zoom = true
		self.config.object.states.drag.is = state
	end
	if self.children then
		for k, v in pairs(self.children) do
			v:set_drag_state(state)
		end
	end
end

function MoveableContainer:hover()
	if self.states.drag.can then
		self:juice_up(0.05, 0.02)
		self.UIRoot:set_hover_state(true)
		play_sound('chips1', math.random() * 0.1 + 0.55, 0.15)
	end

	UIBox.hover(self)
end

function MoveableContainer:stop_hover()
	self.UIRoot:set_hover_state(false)
	UIBox.stop_hover(self)
end

function MoveableContainer:drag()
	self.UIRoot:set_drag_state(true)
	UIBox.drag(self)
end

function MoveableContainer:stop_drag()
	self.UIRoot:set_drag_state(false)
	UIBox.stop_drag(self)
end
