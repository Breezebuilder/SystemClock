-- Originally MoveableContainer from BalaLib by Toeler (https://github.com/Toeler/Balatro-HandPreview/blob/main/Mods/BalaLib/BalaLib.lua) used under GPLv3
-- Modified for use in Ankh by MathIsFun0 (https://github.com/MathIsFun0/Ankh)
-- Further modified for use in SystemClock

local DraggableContainer = UIBox:extend()
function DraggableContainer:init(args)
	Moveable.init(self, args)

	self.states.drag.can = args.can_drag or false
	self.states.collide.can = true
	self.draw_layers = {}

	self.definition = args.definition

	if args.config then
        self.config = args.config
		if self.config.h_popup then
			self.config.h_popup_config = self.config.h_popup_config or { align = self.T.y > G.ROOM.T.h / 2 and 'tm' or 'bm' }
			self.config.h_popup_config.parent = self
		end
        args.config.major = args.config.major or args.config.parent or self

        self:set_alignment({
            major = args.config.major or G,
            type = args.config.align or args.config.type or '',
            bond = args.config.bond or 'Strong',
            offset = args.config.offset or { x = 0, y = 0 },
            lr_clamp = args.config.lr_clamp
        })
        self:set_role{
            xy_bond = args.config.xy_bond,
            r_bond = args.config.r_bond,
            wh_bond = args.config.wh_bond or 'Weak',
            scale_bond = args.config.scale_bond or 'Weak'
        }

        self.states.collide.can = ((args.config.can_collide ~= nil) and args.config.can_collide) or self.states.collide.can

        self.parent = self.config.parent
    end

    self:set_parent_child(self.definition, nil)
    self.Mid = self.Mid or self.UIRoot
    self:calculate_xywh(self.UIRoot, self.T)

    self.T.w = self.UIRoot.T.w
    self.T.h = self.UIRoot.T.h
    self.UIRoot:set_wh()

    self.UIRoot:set_alignments()

	self.VT.x = args.VT.x or self.T.x
	self.VT.y = args.VT.y or self.T.y
    self.VT.w, self.VT.h = self.T.w, self.T.h

    if self.Mid ~= self and self.Mid.parent and false then
        self.VT.x = self.VT.x - self.Mid.role.offset.x + (self.Mid.parent.config.padding or 0)
        self.VT.y = self.VT.y - self.Mid.role.offset.y + (self.Mid.parent.config.padding or 0)
    end

    if self.alignment and self.alignment.lr_clamp then self:lr_clamp() end

    self.UIRoot:initialize_VT(true)

	self.zoom = args.zoom or args.config.zoom
	if self.zoom then self.UIRoot:set_zoom(true, true) end

	if args.config.instance_type == 'POPUP' and not self.created_on_pause then
		self.created_on_pause = true
		self.UIRoot:set_created_on_pause(true, true)
	end

	self.attention_text = 'DraggableContainer'

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

function Moveable:set_created_on_pause(state, recursive, force)
	if self.created_on_pause == state and not force then return end

	self.created_on_pause = state
	if self.config.object then self.config.object.created_on_pause = state end

	if recursive and self.children then
		for k, v in pairs(self.children) do
			v:set_created_on_pause(state, true, force)
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

function DraggableContainer:hover()
	if self.states.drag.can then
		self:juice_up(0.05, 0.02)
		play_sound('chips1', math.random() * 0.1 + 0.55, 0.15)
		if self.zoom then
			self.UIRoot:set_hover_state(true, true)
		end
	end

	UIBox.hover(self)
end

function DraggableContainer:stop_hover()
	if self.zoom then
		self.UIRoot:set_hover_state(false, true)
	end
	UIBox.stop_hover(self)
end

function DraggableContainer:drag()
	if self.zoom then
		self.UIRoot:set_drag_state(true, true)
	end
	UIBox.drag(self)
end

function DraggableContainer:stop_drag()
	if self.zoom then
		self.UIRoot:set_drag_state(false, true)
	end

    if self.config.h_popup then
        self.config.h_popup_config.align = self.T.y > G.ROOM.T.h / 2 and 'tm' or 'bm'
    end

	UIBox.stop_drag(self)
end

return DraggableContainer
