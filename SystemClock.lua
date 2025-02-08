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

SystemClock.CLOCK_FORMATS = {
	{'%I:%M %p', 	true},
	{'%I:%M', 	 	true},
	{'%H:%M', 		false},
	{'%I:%M:%S %p', true},
	{'%I:%M:%S', 	true},
	{'%H:%M:%S', 	false}
}

SystemClock.COLOURS = {
	G.C.WHITE, G.C.JOKER_GREY, G.C.GREY, G.C.L_BLACK, G.C.BLACK,
	G.C.RED, G.C.SECONDARY_SET.Voucher, G.C.ORANGE, G.C.GOLD,
	G.C.GREEN, G.C.SECONDARY_SET.Planet, G.C.BLUE, G.C.PERISHABLE, G.C.BOOSTER,
    G.C.PURPLE, G.C.SECONDARY_SET.Tarot, G.C.ETERNAL, G.C.EDITION
}

SystemClock.FONT_SIZES = {
	0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
	1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0
}
SystemClock.EXAMPLE_FORMATS = {}

SystemClock.time = ''
SystemClock.drawOverAll = false

SMODS.load_file('config_tab.lua')()
SMODS.load_file('MoveableContainer.lua')()

function SystemClock.format_time(formatIndex, time)
	local format_string = SystemClock.CLOCK_FORMATS[formatIndex][1] or '%H:%M'
	local formatted_time = os.date(format_string, time)
	if SystemClock.CLOCK_FORMATS[formatIndex][2] then
		formatted_time = formatted_time:gsub("^0", "")
	end
	return formatted_time
end

function SystemClock.generate_example_time_formats()
	local example_time = os.time({year = 2015, month = 10, day = 21, hour = 16, min = 29, sec = 33})
	for i, format in ipairs(SystemClock.CLOCK_FORMATS) do
		SystemClock.EXAMPLE_FORMATS[i] = SystemClock.format_time(i, example_time)
	end
end

SystemClock.generate_example_time_formats()

SystemClock.game_update_ref = Game.update
function Game:update(dt)
	SystemClock.game_update_ref(self, dt)
	SystemClock.update(dt)
end

SystemClock.game_start_run_ref = Game.start_run
function Game:start_run(args)
	SystemClock.game_start_run_ref(self, args)
	SystemClock.reset_clock_ui()
end

function SystemClock.set_draw_over_all(state)
	if SystemClock.drawOverAll ~= state then
		SystemClock.drawOverAll = state
		SystemClock.reset_clock_ui()
	end
end

SystemClock.g_funcs_exit_mods_ref = G.FUNCS.exit_mods
function G.FUNCS:exit_mods(e)
	SystemClock.set_draw_over_all(false)
	SystemClock.g_funcs_exit_mods_ref(self, e)
end

SystemClock.g_funcs_mods_button_ref = G.FUNCS.mods_button
function G.FUNCS:mods_button(e)
	SystemClock.set_draw_over_all(false)
	SystemClock.g_funcs_mods_button_ref(self, e)
end

function SystemClock.update(dt)
	if G.STAGE == G.STAGES.RUN and SystemClock.config.clockVisible then
		SystemClock.time = SystemClock.format_time(SystemClock.config.clockTimeFormatIndex)
	end
end

function SystemClock.create_UIBox_clock()
	return {
		n = G.UIT.ROOT,
		config = {
			align = 'cm',
			padding = 0.03,
			colour = SystemClock.config.clockStyleIndex > 2 and G.C.UI.TRANSPARENT_DARK or G.C.CLEAR,
			r = 0.1
		},
		nodes = {{
			n = G.UIT.R,
			config = {
				align = 'cm',
				padding = 0.05,
				colour = SystemClock.config.clockStyleIndex > 3 and G.C.DYN_UI.MAIN or G.C.CLEAR,
				r = 0.1
			},
			nodes = {{
				n = G.UIT.R,
				config = {
					align = 'cm',
					colour = SystemClock.config.clockStyleIndex > 3 and G.C.DYN_UI.BOSS_DARK or G.C.CLEAR,
					r = 0.1,
					minw = 0.5,
					padding = 0.03
				},
				nodes = {{
					n = G.UIT.R,
					config = {
						align = 'cm',
					},
					nodes = {}
				}, {
					n = G.UIT.R,
					config = {
						id = 'clock_right',
						align = 'cm',
						padding = 0.03,
						minw = 1,
						emboss = 0.05,
						r = 0.1
					},
					nodes = {{
						n = G.UIT.O,
						config = {
							align = 'cm',
							object = DynaText({
								string = {{
									ref_table = SystemClock,
									ref_value = 'time'
								}},
								colours = SystemClock.config.clockColour,
								scale = SystemClock.config.clockTextSize,
								shadow = (SystemClock.config.clockStyleIndex == 2),
								pop_in = 0,
								pop_in_rate = 10,
								silent = true
							}),
							id = 'clock'
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
				align = 'cr',
				offset = {
					x = 0,
					y = 0
				},
				major = G,
				instance_type = SystemClock.drawOverAll and 'POPUP'
			},
			nodes = {SystemClock.create_UIBox_clock()}
		}
		G.HUD_clock.states.drag.can = SystemClock.config.clockAllowDrag
		G.HUD_clock.T.x = SystemClock.config.clockX
		G.HUD_clock.T.y = SystemClock.config.clockY

		G.HUD_clock.move = function(self, dt)
			MoveableContainer.move(self, dt)
			SystemClock.config.clockX = self.T.x
			SystemClock.config.clockY = self.T.y
		end

		G.HUD_clock.stop_drag = function(self)
			MoveableContainer.stop_drag(self)
			SystemClock.save_mod_config()
		end
	end
end

function SystemClock.save_mod_config()
	local status, err = pcall(SMODS.save_mod_config(mod_instance))
	if status == false then
		sendErrorMessage("Failed to perform a manual mod config save: "..err, 'SystemClock')
	end
end

G.FUNCS.sysclock_change_clock_time_format = function(e)
	SystemClock.config.clockTimeFormatIndex = e.to_key
end

G.FUNCS.sysclock_change_clock_style = function(e)
	SystemClock.config.clockStyleIndex = e.to_key
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_colour = function(e)
	SystemClock.config.clockColourIndex = e.to_key
	SystemClock.config.clockColour = {SystemClock.COLOURS[e.to_key]}
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_change_clock_size = function(e)
	SystemClock.config.clockTextSizeIndex = e.to_key
	SystemClock.config.clockTextSize = e.to_val
	SystemClock.reset_clock_ui()
end

G.FUNCS.sysclock_set_position_x = function(e)
	local x = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.x = x
	end
end

G.FUNCS.sysclock_set_position_y = function(e)
	local y = e.ref_table[e.ref_value]
	if G.HUD_clock then
		G.HUD_clock.T.y = y
	end
end
