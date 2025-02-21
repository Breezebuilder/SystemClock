local config_ui = require('systemclock.config_ui')
local config = require('systemclock.config')
local logger = require('systemclock.logger')

if not SMODS then
	logger.log_warn('SMODS initialiser could not find SMODS instance')
	return
end

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

SMODS.current_mod.config_tab = config_ui.create_config_tab

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

local smods_save_all_config_ref = SMODS.save_all_config
function SMODS.save_all_config()
	smods_save_all_config_ref()
	config.save()
end
