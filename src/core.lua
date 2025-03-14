SystemClock = {}

SystemClock.CLOCK_FORMATS = {
	{ format_string = '%I:%M %p',    leading_zero = false },
	{ format_string = '%I:%M',       leading_zero = false },
	{ format_string = '%H:%M',       leading_zero = true },
	{ format_string = '%I:%M:%S %p', leading_zero = false },
	{ format_string = '%I:%M:%S',    leading_zero = false },
	{ format_string = '%H:%M:%S',    leading_zero = true }
}

SystemClock.COLOUR_REFS = {
	'WHITE', 'JOKER_GREY', 'GREY', 'L_BLACK', 'BLACK',
	'RED', 'SECONDARY_SET.Voucher', 'ORANGE', 'GOLD', 'GREEN',
	'SECONDARY_SET.Planet', 'BLUE', 'PERISHABLE', 'BOOSTER', 'PURPLE',
	'SECONDARY_SET.Tarot', 'ETERNAL', 'EDITION', 'DARK_EDITION', 'DYN_UI.MAIN',
	'DYN_UI.DARK', 'DYN_UI.BOSS_MAIN', 'DYN_UI.BOSS_DARK'
}

SystemClock.TEXT_SIZES = {
	0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
}

SystemClock.STYLES = {
	'simple', 'shadow', 'translucent', 'emboss', 'panel', 'throwback'
}

SystemClock.FORMAT_EXAMPLES = {}

SystemClock.time = ''
SystemClock.current_preset = {}
SystemClock.indices = {}
SystemClock.current_format = {}
SystemClock.example_time = os.time({ year = 2015, month = 10, day = 21, hour = 16, min = 29, sec = 33 })
SystemClock.draw_as_popup = false

local config = require('systemclock.config')
local clock_ui = require('systemclock.clock_ui')
local config_ui = require('systemclock.config_ui')
local logger = require('systemclock.logger')
local utilities = require('systemclock.utilities')

config.load()
config.save()

function SystemClock.assign_clock_colours()
	local text_colour = SystemClock.current_preset.colours and utilities.parse_colour(SystemClock.current_preset.colours.text) or G.C.WHITE
	local back_colour = SystemClock.current_preset.colours and utilities.parse_colour(SystemClock.current_preset.colours.back) or { 1, 0, 1, 1 }
	local shadow_colour = darken(back_colour, 0.3)

	SystemClock.colours = SystemClock.colours or {}
	SystemClock.colours.text = text_colour
	SystemClock.colours.back = back_colour
	SystemClock.colours.shadow = shadow_colour

	return SystemClock.colours
end

local function assign_current_format(format)
	format = format or SystemClock.current_preset.format or 1

	local format_type = type(format)
	if format_type == 'number' then
		SystemClock.current_format = SystemClock.CLOCK_FORMATS[format]
	elseif format_type == 'string' then
		SystemClock.current_format = { format_string = format, leading_zero = false }
	else
		SystemClock.current_format = SystemClock.CLOCK_FORMATS[1]
	end
end

local function assign_config_preset(preset_index)
	preset_index = preset_index or config.clock_preset_index or 0
	config.clock_preset_index = preset_index

	SystemClock.current_preset = config.clock_presets[preset_index]
	if not SystemClock.current_preset then
		logger.log_warn("Error loading clock preset with index " .. tostring(preset_index))
		SystemClock.current_preset = config.get_preset_default(1)
	end

	SystemClock.indices.format = tonumber(SystemClock.current_preset.format) or 0
	SystemClock.indices.style = utilities.index_of(SystemClock.STYLES, SystemClock.current_preset.style) or 0
	SystemClock.indices.size = utilities.index_of(SystemClock.TEXT_SIZES, SystemClock.current_preset.size) or 0
	SystemClock.indices.text_colour = SystemClock.current_preset.colours and utilities.index_of(SystemClock.COLOUR_REFS, SystemClock.current_preset.colours.text) or 0
	SystemClock.indices.back_colour = SystemClock.current_preset.colours and utilities.index_of(SystemClock.COLOUR_REFS, SystemClock.current_preset.colours.back) or 0
	SystemClock.draw_as_popup = (not not config.clock_persistent) or config_ui.is_open

	SystemClock.assign_clock_colours()
	assign_current_format()
end

function SystemClock.get_formatted_time(format_string, leading_zero, time, hour_offset)
	format_string = format_string or SystemClock.current_format.format_string
	leading_zero = leading_zero ~= nil and leading_zero or SystemClock.current_format.leading_zero

	if hour_offset and tonumber(hour_offset) then
		time = time or os.time()
		time = time + tonumber(hour_offset) * 3600
	end

	local formatted_time = os.date(format_string, time)

	if leading_zero == false then
		formatted_time = tostring(formatted_time):gsub("^0", "")
	end
	return formatted_time
end

local function generate_example_time_formats()
	for i, format_set in ipairs(SystemClock.CLOCK_FORMATS) do
		SystemClock.FORMAT_EXAMPLES[i] = SystemClock.get_formatted_time(format_set.format_string, format_set.leading_zero, SystemClock.example_time)
	end
end

assign_config_preset()
generate_example_time_formats()

local game_update_ref = Game.update
function Game:update(dt)
	local ret = game_update_ref(self, dt)

	if config then
		SystemClock.time = SystemClock.get_formatted_time(nil, nil, nil, config.hour_offset)

		if clock_ui.has_dynamic_shadow_colour then
			SystemClock.colours.shadow[1] = SystemClock.colours.back[1] * 0.7
			SystemClock.colours.shadow[2] = SystemClock.colours.back[2] * 0.7
			SystemClock.colours.shadow[3] = SystemClock.colours.back[3] * 0.7
		end
	end

	return ret
end

local game_main_menu_ref = Game.main_menu
function Game:main_menu(change_context)
	local ret = game_main_menu_ref(self, change_context)
	local juice_on_start = config and config.clock_right_click_tutorial
	clock_ui.reset(juice_on_start)
	return ret
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
	local ret = game_start_run_ref(self, args)
	clock_ui.reset()
	return ret
end

local g_funcs_exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(e)
	config_ui.close_config_menu()
	config.save()
	return g_funcs_exit_overlay_menu_ref(e)
end

local g_funcs_set_Trance_font_ref = G.FUNCS.set_Trance_font
function G.FUNCS.set_Trance_font(...)
	if g_funcs_set_Trance_font_ref then
		local ret = { g_funcs_set_Trance_font_ref(...) }
		clock_ui.reset()
		return unpack(ret)
	end
end

local controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
	if G.HUD_clock and G.HUD_clock.states.hover.is then
		config.clock_right_click_tutorial = false
		if config_ui.is_open then
			clock_ui.reset(true)
		else
			config_ui.open_config_menu()
		end
	end
	return controller_queue_R_cursor_press_ref(self, x, y)
end

local g_funcs_change_tab_ref = G.FUNCS.change_tab
function G.FUNCS.change_tab(e)
	config_ui.close_config_menu()
	return g_funcs_change_tab_ref(e)
end

local g_funcs_options_ref = G.FUNCS.options
function G.FUNCS.options(e)
	config_ui.close_config_menu()
	return g_funcs_options_ref(e)
end

function SystemClock.set_popup(state)
	if config.clock_persistent then
		SystemClock.draw_as_popup = true
		clock_ui.reset(state)
	elseif SystemClock.draw_as_popup ~= state then
		SystemClock.draw_as_popup = state
		clock_ui.reset(state)
	end
end

function SystemClock.set_position(pos)
	SystemClock.current_preset.position = pos
	config.save()
	config_ui.update_position_sliders()
end

function SystemClock.set_visibility(state, juice_config)
	config.clock_visible = state
	clock_ui.reset(true)
	config_ui.update_visibility_toggle(juice_config)
	if not state and config.clock_persistent then SystemClock.set_persistent(false, true) end
end

function SystemClock.set_persistent(state, juice_config)
	config.clock_persistent = state
	clock_ui.reset(true)
	config_ui.update_persistent_toggle(juice_config)
	if state and not config.clock_visible then SystemClock.set_visibility(true, true) end
end

function SystemClock.set_draggable(state, juice)
	config.clock_allow_drag = state
	if G.HUD_clock then
		G.HUD_clock.states.drag.can = state or config_ui.is_open
		if juice then G.HUD_clock:juice_up(0.05, 0.03) end
	end
	config_ui.update_draggable_toggle(juice)
end

G.FUNCS.sysclock_cycle_clock_preset = function(e)
	assign_config_preset(e.to_key)
	clock_ui.reset()
	config_ui.update_panel(true)
end

G.FUNCS.sysclock_restore_preset_defaults = function(e)
	config.reset_preset(config.clock_preset_index)
	assign_config_preset()
	clock_ui.reset(true)
	config_ui.update_panel(true)
end

G.FUNCS.sysclock_cycle_clock_time_format = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	SystemClock.indices.format = e.to_key
	SystemClock.current_preset.format = SystemClock.indices.format
	SystemClock.current_format = SystemClock.CLOCK_FORMATS[e.to_key]
	clock_ui.reset(true)
end

G.FUNCS.sysclock_cycle_clock_style = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	SystemClock.indices.style = e.to_key
	SystemClock.current_preset.style = SystemClock.STYLES[e.to_key]
	clock_ui.reset(true)
end

G.FUNCS.sysclock_cycle_clock_text_colour = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	SystemClock.indices.text_colour = e.to_key
	local text_colour_ref = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current_preset.colours.text = text_colour_ref
	clock_ui.reset()
end

G.FUNCS.sysclock_cycle_clock_back_colour = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	SystemClock.indices.back_colour = e.to_key
	local back_colour_ref = SystemClock.COLOUR_REFS[e.to_key]
	SystemClock.current_preset.colours.back = back_colour_ref
	clock_ui.reset()
end

G.FUNCS.sysclock_cycle_clock_size = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	SystemClock.indices.size = e.to_key
	SystemClock.current_preset.size = e.to_val
	clock_ui.reset(true)
end

G.FUNCS.sysclock_slider_clock_position_x = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	local x = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.x = x
	end
	SystemClock.current_preset.position.x = x
end

G.FUNCS.sysclock_slider_clock_position_y = function(e)
	if not config.clock_visible then SystemClock.set_visibility(true, true) end
	local y = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.y = y
	end
	SystemClock.current_preset.position.y = y
end

return SystemClock