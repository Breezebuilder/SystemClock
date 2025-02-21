local config_ui = {}

local logger = require('systemclock.logger')
local config = require('systemclock.config')
local locale = require('systemclock.locale')

function config_ui.create_config_tab()
	SystemClock.set_popup(true)
	return {
		n = G.UIT.ROOT,
		config = {
			r = 0.1,
			minh = 6,
			minw = 6,
			align = 'cm',
			colour = G.C.CLEAR
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { align = 'tl', minw = 2, id = 'sysclock_config_sidebar' },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = 'tr', id = 'sysclock_config_toggles' },
						nodes = {
							{
								n = G.UIT.C,
								nodes = {
									{
										n = G.UIT.R,
										config = { align = 'tr', padding = 0.05 },
										nodes = {
											{
												n = G.UIT.O,
												config = {
													id = 'sysclock_visibility_toggle',
													object = UIBox {
														config = { align = 'cm', offset = { x = 0, y = 0 } },
														definition = config_ui.create_UIBox_visibility_toggle()
													}
												}
											}
										}
									},
									{
										n = G.UIT.R,
										config = { align = 'tr', padding = 0.05 },
										nodes = {
											{
												n = G.UIT.O,
												config = {
													id = 'sysclock_draggable_toggle',
													object = UIBox {
														config = { align = 'cm', offset = { x = 0, y = 0 } },
														definition = config_ui.create_UIBox_draggable_toggle()
													}
												}
											}
										}
									},
									{
										n = G.UIT.R,
										config = { minh = 1.5 },
									},
									{
										n = G.UIT.R,
										config = { align = 'cm' },
										nodes = {
											create_option_cycle({
												label = locale.translate('sysclock_preset_setting'),
												scale = 0.8,
												text_scale = 0.7,
												w = 2,
												h = 0.8,
												options = { "1", "2", "3", "4", "5" },
												current_option = config.clock_preset_index,
												opt_callback = 'sysclock_cycle_clock_preset',
												colour = G.C.JOKER_GREY,
											}),
										}
									},
									{
										n = G.UIT.R,
										config = { minh = 0.2 }
									},
									{
										n = G.UIT.R,
										config = { align = 'cm' },
										nodes = {
											UIBox_button({
												button = 'sysclock_restore_preset_defaults',
												label = { locale.translate('sysclock_preset_default_button') },
												colour = G.C.JOKER_GREY,
												minw = 2.8,
												minh = 0.6,
												scale = 0.5 * 0.8,
											})
										}
									}
								}
							}
						}
					}
				}
			},
			{
				n = G.UIT.C,
				config = { minw = 0.2 }
			},
			{
				n = G.UIT.C,
				nodes = {
					{
						n = G.UIT.O,
						config = {
							id = 'sysclock_config_panel',
							object = UIBox {
								config = { align = 'cm', offset = { x = 0, y = 0 } },
								definition = config_ui.create_UIBox_config_panel()
							}
						}
					}
				}
			}
		}
	}
end

function config_ui.create_UIBox_config_panel()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', minw = 10, r = 0.1, emboss = 0.1, colour = G.C.GREY },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = 'tm', minw = 5.2, id = 'sysclock_config_panel_column_left' },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = 'tl' },
						nodes = {
							create_option_cycle({
								label = locale.translate('sysclock_time_format_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.FORMAT_EXAMPLES,
								current_option = SystemClock.indices.format,
								opt_callback = 'sysclock_cycle_clock_time_format'
							}),
						}
					},
					{
						n = G.UIT.R,
						config = { minh = 1.4 },
					},
					{
						n = G.UIT.R,
						config = { align = 'bl' },
						nodes = {
							{
								n = G.UIT.O,
								config = {
									id = 'sysclock_config_position_sliders',
									object = UIBox {
										config = { align = 'cm', offset = { x = 0, y = 0 } },
										definition = config_ui.create_UIBox_position_sliders()
									}
								}
							}
						}
					}
				}
			},
			{
				n = G.UIT.C,
				config = { align = 'tr', minw = 5.2, id = 'sysclock_config_panel_column_right' },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = locale.translate('sysclock_size_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.TEXT_SIZES,
								current_option = SystemClock.indices.size,
								opt_callback = 'sysclock_cycle_clock_size',
								colour = G.C.GREEN
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = locale.translate('sysclock_style_setting'),
								scale = 0.8,
								w = 4.5,
								options = locale.translate('sysclock_styles'),
								current_option = SystemClock.indices.style,
								opt_callback = 'sysclock_cycle_clock_style',
								colour = G.C.ORANGE
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = locale.translate('sysclock_text_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = locale.translate('sysclock_colours'),
								current_option = SystemClock.indices.text_colour,
								opt_callback = 'sysclock_cycle_clock_text_colour',
								colour = G.C.BLUE
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = locale.translate('sysclock_back_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = locale.translate('sysclock_colours'),
								current_option = SystemClock.indices.back_colour,
								opt_callback = 'sysclock_cycle_clock_back_colour',
								colour = G.C.BLUE
							})
						}
					}
				}
			}
		}
	}
end

function config_ui.create_UIBox_visibility_toggle()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = 'cm' },
				nodes = {
					create_toggle({
						label = locale.translate('sysclock_visibility_setting'),
						w = 1.5,
						text_scale = 0.8,
						ref_table = config,
						ref_value = 'clock_visible',
						callback = SystemClock.set_visibility
					})
				}
			}
		}
	}
end

function config_ui.create_UIBox_draggable_toggle()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = 'cm' },
				nodes = {
					create_toggle({
						label = locale.translate('sysclock_draggable_setting'),
						w = 1.5,
						text_scale = 0.8,
						ref_table = config,
						ref_value = 'clock_allow_drag',
						callback = SystemClock.set_draggable
					})
				}
			}
		}
	}
end

function config_ui.create_UIBox_position_sliders()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = 'tm', padding = 0.1 },
				nodes = {
					create_slider({
						label = locale.translate('sysclock_x_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = SystemClock.current_preset.position,
						ref_value = 'x',
						w = 4,
						min = -4,
						max = 22,
						step = 0.01,
						decimal_places = 2,
						callback = 'sysclock_slider_clock_position_x'
					})
				}
			},
			{
				n = G.UIT.R,
				config = { align = 'bm', padding = 0.1 },
				nodes = {
					create_slider({
						label = locale.translate('sysclock_y_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = SystemClock.current_preset.position,
						ref_value = 'y',
						w = 4,
						min = -3,
						max = 13,
						step = 0.01,
						decimal_places = 2,
						callback = 'sysclock_slider_clock_position_y'
					})
				}
			}
		}
	}
end

function config_ui.update_panel(juice)
	local panel_contents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_panel')
	if not panel_contents then return end

	panel_contents.config.object:remove()
	panel_contents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = panel_contents },
		definition = config_ui.create_UIBox_config_panel(),
	}
	panel_contents.UIBox:recalculate()
	panel_contents.config.object:set_role {
		role_type = 'Major',
		major = nil
	}

	if juice then panel_contents.config.object:juice_up(0.05, 0.02) end
end

function config_ui.update_visibility_toggle(juice)
	local toggle_contents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_visibility_toggle')
	if not toggle_contents then return end

	toggle_contents.config.object:remove()
	toggle_contents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = toggle_contents },
		definition = config_ui.create_UIBox_visibility_toggle()
	}
	toggle_contents.UIBox:recalculate()
	toggle_contents.config.object:set_role {
		role_type = 'Major',
		major = nil
	}

	if juice then toggle_contents.config.object:juice_up(0.05, 0.05) end
end

function config_ui.update_draggable_toggle(juice)
	local toggle_contents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_draggable_toggle')
	if not toggle_contents then return end

	toggle_contents.config.object:remove()
	toggle_contents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = toggle_contents },
		definition = config_ui.create_UIBox_draggable_toggle()
	}
	toggle_contents.UIBox:recalculate()
	toggle_contents.config.object:set_role {
		role_type = 'Major',
		major = nil
	}

	if juice then toggle_contents.config.object:juice_up(0.05, 0.05) end
end

function config_ui.update_position_sliders()
	local panel_contents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_position_sliders')
	if not panel_contents then return end

	panel_contents.config.object:remove()
	panel_contents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = panel_contents },
		definition = config_ui.create_UIBox_position_sliders()
	}
	panel_contents.UIBox:recalculate()
end

function config_ui.open_config_menu()
	if SMODS then
		if G.FUNCS.openModUI_SystemClock then
			SMODS.LAST_SELECTED_MOD_TAB = 'config'
			G.FUNCS.openModUI_SystemClock()
			local back_button_uie = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('overlay_menu_back_button')
			if back_button_uie then
				back_button_uie.config.button = 'exit_overlay_menu'
			end
			return
		else
			logger.log_warn("G.FUNCS.openModUI_SystemClock does not exist, falling back to vanilla config menu")
		end
	end

	G.FUNCS.overlay_menu(
		{
			definition = create_UIBox_generic_options({
				back_func = 'exit_overlay_menu',
				contents = {
					create_tabs({
						no_shoulders = true,
						colour = G.C.BOOSTER,
						tabs = { {
							label = "SystemClock",
							chosen = true,
							tab_definition_function = config_ui.create_config_tab
						} },
					})
				}
			})
		}
	)
end

return config_ui
