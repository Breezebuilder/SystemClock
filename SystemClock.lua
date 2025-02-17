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

SMODS.load_file('back_compat.lua')()
SMODS.load_file('clock_ui.lua')()
SMODS.load_file('config_ui.lua')()
SMODS.load_file('MoveableContainer.lua')()

SMODS.current_mod.config_tab = SystemClock.config_ui

SystemClock.CLOCK_FORMATS = {
	{ '%I:%M %p',    true },
	{ '%I:%M',       true },
	{ '%H:%M',       false },
	{ '%I:%M:%S %p', true },
	{ '%I:%M:%S',    true },
	{ '%H:%M:%S',    false }
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
SystemClock.colours = {}
SystemClock.example_time = os.time({ year = 2015, month = 10, day = 21, hour = 16, min = 29, sec = 33 })
SystemClock.draw_as_popup = false

local function index_of(table, val)
	if not val then return nil end
	for i, v in ipairs(table) do
		if v == val then return i end
	end
	return nil
end

function SystemClock.get_colour_from_ref(ref)
	if not ref then return nil end

	local depth = 0
	local colour = G.C
	for obj_name in ref:gmatch("[^%.]+") do
		colour = colour[obj_name]
		depth = depth + 1
		if depth > 2 or not colour then
			return nil
		end
	end
	return type(colour) == 'table' and colour
end

function SystemClock.assign_clock_colours()
	local text_colour = SystemClock.get_colour_from_ref(SystemClock.current.colours.text)
	local back_colour = SystemClock.get_colour_from_ref(SystemClock.current.colours.back)
	local shadow_colour = darken(back_colour, 0.3)

	SystemClock.colours = {
		text = text_colour,
		back = back_colour,
		shadow = shadow_colour
	}

	return SystemClock.colours
end

function SystemClock.init_config_preset(presetIndex)
	presetIndex = presetIndex or SystemClock.config.clock_preset_index
	SystemClock.config.clock_preset_index = presetIndex

	SystemClock.current = SystemClock.config.clock_presets[presetIndex]
	SystemClock.indices.format = SystemClock.current.format or 1
	SystemClock.indices.style = SystemClock.current.style or 1
	SystemClock.indices.size = index_of(SystemClock.TEXT_SIZES, SystemClock.current.size) or 1
	SystemClock.indices.text_colour = index_of(SystemClock.COLOUR_REFS, SystemClock.current.colours.text) or 1
	SystemClock.indices.back_colour = index_of(SystemClock.COLOUR_REFS, SystemClock.current.colours.back) or 1
	SystemClock.assign_clock_colours()
end

function SystemClock.save_config()
	if not (SMODS.save_mod_config(mod_instance)) then
		sendErrorMessage("Failed to perform a manual mod config save", 'SystemClock')
	end
end

function SystemClock.get_formatted_time(format_style, time, force_leading_zero, hour_offset)
	format_style = format_style or SystemClock.CLOCK_FORMATS[SystemClock.indices.format]
	if hour_offset then
		if time == nil then
			time = os.time()
		end
		time = time + (hour_offset * 3600)
	end
	local formatted_time = os.date(format_style[1], time)
	if not force_leading_zero and format_style[2] then
		formatted_time = tostring(formatted_time):gsub("^0", "")
	end
	return formatted_time
end

function SystemClock.generate_example_time_formats()
	for i, format_style in ipairs(SystemClock.CLOCK_FORMATS) do
		SystemClock.FORMAT_EXAMPLES[i] = SystemClock.get_formatted_time(format_style, SystemClock.example_time)
	end
end

SystemClock.update_config_version()
SystemClock.init_config_preset()
SystemClock.generate_example_time_formats()

local game_update_ref = Game.update
function SystemClock.hook_game_update(state)
	if state == false then
		Game.update = game_update_ref
	else
		function Game:update(dt)
			game_update_ref(self, dt)
			SystemClock.update(dt)
		end
	end
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
	game_start_run_ref(self, args)
	SystemClock.hook_game_update(true)
	SystemClock.reset_clock_ui()
end

local g_funcs_exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(e)
	SystemClock.set_popup(false)
	g_funcs_exit_overlay_menu_ref(e)
end

if SMODS then
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
		if e and e.config and e.config.id == 'tab_but_SystemClock' then
			SystemClock.set_popup(false)
		end
		g_funcs_change_tab_ref(e)
	end
end

local g_funcs_set_Trance_font = G.FUNCS.set_Trance_font
function G.FUNCS.set_Trance_font(...)
	if g_funcs_set_Trance_font then
		local ret = { g_funcs_set_Trance_font(...) }
		SystemClock.reset_clock_ui()
		return unpack(ret)
	end
end

local controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    if self.locks.frame then return end
	if G.HUD_clock and G.HUD_clock.states.hover.is and not SystemClock.draw_as_popup then
		SystemClock.open_config_menu()
	end
	controller_queue_R_cursor_press_ref(self, x, y)
end

function SystemClock.update(dt)
	SystemClock.time = SystemClock.get_formatted_time(nil, nil, false, SystemClock.config.hour_offset)

	if SystemClock.indices.style == 5 and SystemClock.indices.back_colour > 17 then
		SystemClock.colours.shadow[1] = SystemClock.colours.back[1]*(0.7)
		SystemClock.colours.shadow[2] = SystemClock.colours.back[2]*(0.7)
		SystemClock.colours.shadow[3] = SystemClock.colours.back[3]*(0.7)
	end

	if G.STAGE ~= G.STAGES.RUN then
		SystemClock.hook_game_update(false)
	end
end

function SystemClock.set_popup(state, forceReset)
	if forceReset or SystemClock.draw_as_popup ~= state then
		SystemClock.draw_as_popup = state
		SystemClock.reset_clock_ui()
	end
end

SystemClock.callback_clock_visibility = function()
	SystemClock.hook_game_update(SystemClock.config.clock_visible)
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_preset = function(e)
	SystemClock.init_config_preset(e.to_key)
	SystemClock.reset_clock_ui()
	SystemClock.update_config_ui()
end

G.FUNCS.sysclock_default_current_preset = function(e)
	SystemClock.config.clock_presets[SystemClock.config.clock_preset_index] = {}
	SystemClock.save_config()
	local loaded_config = SMODS.load_mod_config(mod_instance)
	if loaded_config then
		SystemClock.config.clock_presets = loaded_config.clock_presets
	end
	SystemClock.init_config_preset()
	SystemClock.reset_clock_ui()
	SystemClock.update_config_ui()
end

G.FUNCS.sysclock_change_clock_time_format = function(e)
	SystemClock.indices.format = e.to_key
	SystemClock.current.format = SystemClock.indices.format
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_style = function(e)
	SystemClock.indices.style = e.to_key
	SystemClock.current.style = SystemClock.indices.style
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_text_colour = function(e)
	SystemClock.indices.text_colour = e.to_key
	local text_colour_ref = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current.colours.text = text_colour_ref
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_back_colour = function(e)
	SystemClock.indices.back_colour = e.to_key
	local back_colour_ref = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current.colours.back = back_colour_ref
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_size = function(e)
	SystemClock.indices.size = e.to_key
	SystemClock.current.size = e.to_val
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_set_hud_position_x = function(e)
	local x = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.x = x
	end
	SystemClock.current.position.x = x
end

G.FUNCS.sysclock_set_hud_position_y = function(e)
	local y = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.y = y
	end
	SystemClock.current.position.y = y
end
