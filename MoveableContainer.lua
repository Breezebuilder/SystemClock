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
			scale = 1
		},
		nodes = {{
			n = G.UIT.R,
			nodes = args.nodes or {}
		}}
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

function MoveableContainer:hover()
	if self.states.drag.can then
		self:juice_up(0.08, 0.05)
		self.hovering = true
		play_sound('chips1', math.random() * 0.1 + 0.55, 0.15)
	end
	UIBox.hover(self)
end

function MoveableContainer:stop_hover()
	self.hovering = false
	UIBox.stop_hover(self)
end