SystemClock = {}
SystemClock.path = SMODS.current_mod.path
SystemClock.config = SMODS.current_mod.config
local mod_instance = SMODS.current_mod

SMODS.Atlas({
	key = 'modicon',
	path = 'icon.png',
	px = 32,
	py = 32
})

SMODS.current_mod.description_loc_vars = function(self)
	return {
		scale = 1.2,
		background_colour = G.C.CLEAR
	}
end

SMODS.load_file('config_tab.lua')()
SMODS.load_file('MoveableContainer.lua')()

SystemClock.CLOCK_FORMATS = {
	{'%I:%M %p', 	true},
	{'%I:%M', 	 	true},
	{'%H:%M', 		false},
	{'%I:%M:%S %p', true},
	{'%I:%M:%S', 	true},
	{'%H:%M:%S', 	false}
}

SystemClock.COLOUR_REFS = {
	'WHITE', 'JOKER_GREY', 'GREY', 'L_BLACK', 'BLACK',
	'RED', 'SECONDARY_SET.Voucher', 'ORANGE', 'GOLD',
	'GREEN', 'SECONDARY_SET.Planet', 'BLUE', 'PERISHABLE', 'BOOSTER',
	'PURPLE', 'SECONDARY_SET.Tarot', 'ETERNAL', 'EDITION',
	'DYN_UI.MAIN', 'DYN_UI.DARK'
}

SystemClock.TEXT_SIZES = {
	0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
	1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0
}
SystemClock.FORMAT_EXAMPLES = {}
SystemClock.PRESET_OPTIONS = {}

SystemClock.time = ''
SystemClock.current = {}
SystemClock.indices = {}
SystemClock.exampleTime = os.time({year = 2015, month = 10, day = 21, hour = 16, min = 29, sec = 33})
SystemClock.drawAsPopup = false

local function index_of(table, val)
	if not val then return nil end
    for i, v in ipairs(table) do
        if v == val then return i end
    end
    return nil
end

function SystemClock.update_config_version()
	if SystemClock.config.clockColourIndex then
		sendInfoMessage("Transferring v1 config settings", 'SystemClock')
		SystemClock.config.clockTextColourRef = SystemClock.COLOUR_REFS[SystemClock.config.clockColourIndex]
		SystemClock.config.clockTextColourIndex = SystemClock.config.clockColourIndex
		SystemClock.config.clockColourIndex = nil
		SystemClock.config.clockColour = nil
	elseif SystemClock.config.clockConfigVersion == 2 then
		SystemClock.config.clockPresets[1].format = SystemClock.config.clockTimeFormatIndex
		SystemClock.config.clockPresets[1].style = SystemClock.config.clockStyleIndex
		SystemClock.config.clockPresets[1].size = SystemClock.config.clockTextSize
		SystemClock.config.clockPresets[1].colours.text = SystemClock.config.clockTextColourRef
		SystemClock.config.clockPresets[1].colours.back = SystemClock.config.clockBackColourRef
		SystemClock.config.clockPresets[1].position.x = SystemClock.config.clockX
		SystemClock.config.clockPresets[1].position.y = SystemClock.config.clockY

		SystemClock.config.clockTimeFormatIndex = nil
		SystemClock.config.clockStyleIndex = nil
		SystemClock.config.clockTextColourIndex = nil
		SystemClock.config.clockTextColourRef = nil
		SystemClock.config.clockBackColourIndex = nil
		SystemClock.config.clockBackColourRef = nil
		SystemClock.config.clockTextSize = nil
		SystemClock.config.clockTextSizeIndex = nil
		SystemClock.config.clockX = nil
		SystemClock.config.clockY = nil

		SystemClock.config.clockConfigVersion = 3
	end
end

function SystemClock.load_config_preset(presetIndex)
	presetIndex = presetIndex or SystemClock.config.clockPresetIndex
	SystemClock.config.clockPresetIndex = presetIndex

	SystemClock.current = SystemClock.config.clockPresets[presetIndex]
	SystemClock.indices.format = SystemClock.current.format or 1
	SystemClock.indices.style = SystemClock.current.style or 1
	SystemClock.indices.size = index_of(SystemClock.TEXT_SIZES, SystemClock.current.size) or 1
	SystemClock.indices.textColour = index_of(SystemClock.COLOUR_REFS, SystemClock.current.colours.text) or 1
	SystemClock.indices.backColour = index_of(SystemClock.COLOUR_REFS, SystemClock.current.colours.back) or 1
end

function SystemClock.get_formatted_time(formatRow, time, forceLeadingZero)
	formatRow = formatRow or SystemClock.CLOCK_FORMATS[SystemClock.current.format]
	local formatted_time = os.date(formatRow[1], time)
	if not forceLeadingZero and formatRow[2] then
		formatted_time = tostring(formatted_time):gsub("^0", "")
	end
	return formatted_time
end

function SystemClock.generate_example_time_formats()
	for i, formatRow in ipairs(SystemClock.CLOCK_FORMATS) do
		SystemClock.FORMAT_EXAMPLES[i] = SystemClock.get_formatted_time(formatRow, SystemClock.exampleTime)
	end
end

SystemClock.update_config_version()
SystemClock.load_config_preset()
SystemClock.generate_example_time_formats()

local game_update_ref = Game.update
function Game:update(dt)
	game_update_ref(self, dt)
	SystemClock.update(dt)
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
	game_start_run_ref(self, args)
	SystemClock.reset_clock_ui()
end

local g_funcs_exit_mods_ref = G.FUNCS.exit_mods
function G.FUNCS.exit_mods(e)
	SystemClock.set_popup(false)
	g_funcs_exit_mods_ref(e)
end

local g_funcs_mods_button_ref = G.FUNCS.mods_button
function G.FUNCS.mods_button(e)
	SystemClock.set_popup(false)
	g_funcs_mods_button_ref(e)
end

local g_funcs_change_tab_ref = G.FUNCS.change_tab
function G.FUNCS.change_tab(e)
    if e and e.config and e.config.id == 'tab_but_'..mod_instance.id then
        SystemClock.set_popup(false)
    end
    g_funcs_change_tab_ref(e)
end

local g_funcs_set_Trance_font = G.FUNCS.set_Trance_font
function G.FUNCS.set_Trance_font(...)
	if g_funcs_set_Trance_font then
		local ret = {g_funcs_set_Trance_font(...)}
		SystemClock.reset_clock_ui()
		return table.unpack(ret)
	end
end

function SystemClock.update(dt)
	if G.STAGE == G.STAGES.RUN and SystemClock.config.clockVisible then
		SystemClock.time = SystemClock.get_formatted_time()
	end
end

function SystemClock.set_popup(state)
	if SystemClock.drawAsPopup ~= state then
		SystemClock.drawAsPopup = state
		SystemClock.reset_clock_ui()
	end
end

function SystemClock.calculate_max_text_width(formatIndex)
	formatIndex = formatIndex or SystemClock.current.format
	local format = SystemClock.CLOCK_FORMATS[formatIndex]
	local font = G.LANG.font
	local width = 0
	local string = SystemClock.get_formatted_time(format, SystemClock.exampleTime, true)
	for _, c in utf8.chars(string) do
		local dx = font.FONT:getWidth(c) * SystemClock.current.size * G.TILESCALE * font.FONTSCALE + 3 * G.TILESCALE * font.FONTSCALE
		dx = dx / (G.TILESIZE * G.TILESCALE)
		width = width + dx
	end
	return width
end

function SystemClock.create_UIBox_clock(style, textSize, colours, float)
	style = style or 2
	textSize = textSize or 1
	colours = colours or {text = G.C.WHITE, back = G.C.BLACK}

	local translucentColour = (style == 3 or style == 4) and G.C.UI.TRANSPARENT_DARK or G.C.CLEAR
	local panelOuterColour = (style == 4) and colours.back or G.C.CLEAR
	local panelInnerColour = (style == 4) and G.C.DYN_UI.BOSS_DARK or (style == 5) and colours.back or G.C.CLEAR
	local embossAmount = (style == 5) and 0.05 or 0
	local innerWidth = SystemClock.calculate_max_text_width()

	return {
		n = G.UIT.ROOT,
		config = {
			align = 'cm',
			padding = 0.03,
			colour = translucentColour,
			r = 0.1
		},
		nodes = {{
			n = G.UIT.R,
			config = {
				align = 'cm',
				padding = 0.05,
				colour = panelOuterColour,
				r = 0.1
			},
			nodes = {{
				n = G.UIT.C,
				config = {
					align = 'cm',
					colour = panelInnerColour,
					emboss = embossAmount,
					r = 0.1,
					minw = 0.5,
					padding = 0.03
				},
				nodes = {{
					n = G.UIT.R,
					config = {
						align = 'cm',
						padding = 0.03,
						minw = innerWidth,
						r = 0.1
					},
					nodes = {{
						n = G.UIT.O,
						config = {
							align = 'cm',
							id = 'clock_text',
							object = DynaText({
								string = {{
									ref_table = SystemClock,
									ref_value = 'time'
								}},
								colours = {colours.text},
								scale = textSize,
								shadow = (style > 1),
								pop_in = 0,
								pop_in_rate = 10,
								float = float,
								silent = true
							})
						}
					}}
				}}
			}}
		}}
	}
end

function SystemClock.reset_clock_ui()
	if G.HUD_clock then
		G.HUD_clock:remove()
	end
	if G.STAGE == G.STAGES.RUN and SystemClock.config.clockVisible then
		G.HUD_clock = MoveableContainer {
			config = {
				align = 'cm',
				offset = {
					x = 0,
					y = 0
				},
				major = G,
				instance_type = SystemClock.drawAsPopup and 'POPUP'
			},
			nodes = {
				SystemClock.create_UIBox_clock(
					SystemClock.current.style,
					SystemClock.current.size,
					SystemClock.get_clock_colours(),
					SystemClock.drawAsPopup
				)
			}
		}
		G.HUD_clock.states.drag.can = SystemClock.config.clockAllowDrag
		local position = SystemClock.current.position
		G.HUD_clock.T.x = position.x
		G.HUD_clock.T.y = position.y

		G.HUD_clock.move = function(self, dt)
			MoveableContainer.move(self, dt)
			SystemClock.current.position = {x = self.T.x, y = self.T.y}
		end

		G.HUD_clock.stop_drag = function(self)
			MoveableContainer.stop_drag(self)
			SystemClock.save_mod_config()
			SystemClock.update_config_position_sliders()
		end
	end
end

function SystemClock.update_config_ui()
	local panelContents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_panel')
	if not panelContents then return end

	panelContents.config.object:remove()
    panelContents.config.object = UIBox{
        config = {offset = {x = 0, y = 0}, parent = panelContents},
        definition = SystemClock.create_UIBox_config_panel(),
    }
	panelContents.UIBox:recalculate()
	panelContents.config.object:set_role{
		role_type = 'Major',
		major = nil
	}

	panelContents.config.object:juice_up(0.05, 0.02)
end

function SystemClock.update_config_position_sliders()
	local panelContents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_position_sliders')
	if not panelContents then return end

	panelContents.config.object:remove()
    panelContents.config.object = UIBox{
        config = {offset = {x = 0, y = 0}, parent = panelContents},
        definition = SystemClock.create_UIBox_position_sliders()
      }
	panelContents.UIBox:recalculate()
end

function SystemClock.save_mod_config()
	local okay, err = pcall(SMODS.save_mod_config, mod_instance)
	if not okay then
		sendErrorMessage("Failed to perform a manual mod config save: "..err, 'SystemClock')
	end
end

function SystemClock.get_colour_from_ref(ref)
	if not ref then return nil end

	local depth = 0
	local colour = G.C
	for objName in ref:gmatch("[^%.]+") do
		colour = colour[objName]
		depth = depth + 1
		if depth > 2 or not colour then
			return nil
		end
	end
	return type(colour) == 'table' and colour
end

function SystemClock.get_clock_colours()
	return {
		text = SystemClock.get_colour_from_ref(SystemClock.current.colours.text),
		back = SystemClock.get_colour_from_ref(SystemClock.current.colours.back)
	}
end

G.FUNCS.sysclock_change_clock_preset = function(e)
	SystemClock.load_config_preset(e.to_key)
	SystemClock.reset_clock_ui()
	SystemClock.update_config_ui()
end

G.FUNCS.sysclock_change_clock_time_format = function(e)
	SystemClock.indices.format = e.to_key
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].format = SystemClock.indices.format
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_style = function(e)
	SystemClock.indices.style = e.to_key
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].style = SystemClock.indices.style
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_text_colour = function(e)
	SystemClock.indices.textColour = e.to_key
	local textColourRef = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current.colours.text = textColourRef
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].colours.text = textColourRef
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_back_colour = function(e)
	SystemClock.indices.backColour = e.to_key
	local backColourRef = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current.colours.back = backColourRef
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].colours.back = backColourRef
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_size = function(e)
	SystemClock.indices.size = e.to_key
	SystemClock.current.size = e.to_val
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].size = e.to_val
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_set_hud_position_x = function(e)
	local x = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.x = x
	end
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].position.x = x
end

G.FUNCS.sysclock_set_hud_position_y = function(e)
	local y = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.y = y
	end
	SystemClock.config.clockPresets[SystemClock.config.clockPresetIndex].position.y = y
end
