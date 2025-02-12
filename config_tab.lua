SMODS.current_mod.config_tab = function()
	SystemClock.drawAsPopup = true
	SystemClock.reset_clock_ui()
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
											create_toggle({
												label = localize('sysclock_visibility_setting'),
												w = 1.5,
												text_scale = 0.8,
												ref_table = SystemClock.config,
												ref_value = 'clockVisible',
												callback = SystemClock.reset_clock_ui
											})
										}
									},
									{
										n = G.UIT.R,
										config = { align = 'tr', padding = 0.05 },
										nodes = {
											create_toggle({
												label = localize('sysclock_draggable_setting'),
												w = 1.5,
												text_scale = 0.8,
												ref_table = SystemClock.config,
												ref_value = 'clockAllowDrag',
												callback = SystemClock.reset_clock_ui
											})
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
												label = localize('sysclock_preset_setting'),
												scale = 0.8,
												text_scale = 0.7,
												w = 2,
												h = 0.8,
												options = { "1", "2", "3", "4", "5" },
												current_option = SystemClock.config.clockPresetIndex,
												opt_callback = 'sysclock_change_clock_preset',
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
												button = 'sysclock_default_current_preset',
												label = { localize('sysclock_preset_default_button') },
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
								definition = SystemClock.create_UIBox_config_panel()
							}
						}
					}
				}
			}
		}
	}
end

function SystemClock.create_UIBox_config_panel()
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
								label = localize('sysclock_time_format_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.FORMAT_EXAMPLES,
								current_option = SystemClock.indices.format,
								opt_callback = 'sysclock_change_clock_time_format'
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
										definition = SystemClock.create_UIBox_position_sliders()
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
								label = localize('sysclock_size_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.TEXT_SIZES,
								current_option = SystemClock.indices.size,
								opt_callback = 'sysclock_change_clock_size',
								colour = G.C.GREEN
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = localize('sysclock_style_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_styles'),
								current_option = SystemClock.indices.style,
								opt_callback = 'sysclock_change_clock_style',
								colour = G.C.ORANGE
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = localize('sysclock_text_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_colours'),
								current_option = SystemClock.indices.textColour,
								opt_callback = 'sysclock_change_clock_text_colour',
								colour = G.C.BLUE
							})
						}
					},
					{
						n = G.UIT.R,
						config = { align = 'cr', padding = 0 },
						nodes = {
							create_option_cycle({
								label = localize('sysclock_back_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_colours'),
								current_option = SystemClock.indices.backColour,
								opt_callback = 'sysclock_change_clock_back_colour',
								colour = G.C.BLUE
							})
						}
					}
				}
			}
		}
	}
end

function SystemClock.create_UIBox_position_sliders()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = 'tm', padding = 0.1 },
				nodes = {
					create_slider({
						label = localize('sysclock_x_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = SystemClock.current.position,
						ref_value = 'x',
						w = 4,
						min = -4,
						max = 22,
						step = 0.01,
						decimal_places = 2,
						callback = 'sysclock_set_hud_position_x'
					})
				}
			},
			{
				n = G.UIT.R,
				config = { align = 'bm', padding = 0.1 },
				nodes = {
					create_slider({
						label = localize('sysclock_y_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = SystemClock.current.position,
						ref_value = 'y',
						w = 4,
						min = -3,
						max = 13,
						step = 0.01,
						decimal_places = 2,
						callback = 'sysclock_set_hud_position_y'
					})
				}
			}
		}
	}
end

function SystemClock.update_config_ui()
	local panelContents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_panel')
	if not panelContents then return end

	panelContents.config.object:remove()
	panelContents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = panelContents },
		definition = SystemClock.create_UIBox_config_panel(),
	}
	panelContents.UIBox:recalculate()
	panelContents.config.object:set_role {
		role_type = 'Major',
		major = nil
	}

	panelContents.config.object:juice_up(0.05, 0.02)
end

function SystemClock.update_config_position_sliders()
	local panelContents = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('sysclock_config_position_sliders')
	if not panelContents then return end

	panelContents.config.object:remove()
	panelContents.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = panelContents },
		definition = SystemClock.create_UIBox_position_sliders()
	}
	panelContents.UIBox:recalculate()
end