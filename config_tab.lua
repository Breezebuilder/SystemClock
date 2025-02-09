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
				config = {align = 'tl', minw = 5.5, id = 'sysclock_config_column_left'},
				nodes = {
					{
						n = G.UIT.R,
						config = {align = 'tr', id = 'sysclock_config_toggles'},
						nodes = {
							{
								n = G.UIT.C,
								nodes = {
									{
										n = G.UIT.R,
										config = {align = 'tr', padding = 0.05},
										nodes = {
											create_toggle({
												label = localize('sysclock_visibility_setting'),
												text_scale = 0.8,
												ref_table = SystemClock.config,
												ref_value = 'clockVisible',
												callback = SystemClock.reset_clock_ui
											})
										}
									},
									{
										n = G.UIT.R,
										config = {align = 'tr', padding = 0.05},
										nodes = {
											create_toggle({
												label = localize('sysclock_draggable_setting'),
												text_scale = 0.8,
												ref_table = SystemClock.config,
												ref_value = 'clockAllowDrag',
												callback = SystemClock.reset_clock_ui
											})
										}
									}
								}
							}
						}
					},
					{
						n = G.UIT.R,
						config = {align = 'cl'},
						nodes = {
							create_option_cycle({
								label = localize('sysclock_time_format_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.FORMAT_EXAMPLES,
								current_option = SystemClock.config.clockTimeFormatIndex,
								opt_callback = 'sysclock_change_clock_time_format'
							}),
						}
					},
					{
						n = G.UIT.R,
						config = {align = 'bl', id = 'sysclock_config_position_sliders'},
						nodes = {
							{
								n = G.UIT.C,
								nodes = {
									{
										n = G.UIT.R,
										config = {align = 'bm', padding = 0},
										nodes = {
											create_slider({
												label = localize('sysclock_x_position_setting'),
												scale = 0.8,
												label_scale = 0.8 * 0.5,
												ref_table = SystemClock.config,
												ref_value = 'clockX',
												w = 4,
												min = -4,
												max = 22,
												step = 0.01,
												decimal_places = 2,
												callback = 'sysclock_set_position_x'
											})
										}
									},
									{
										n = G.UIT.R,
										config = {align = 'bm', padding = 0},
										nodes = {
											create_slider({
												label = localize('sysclock_y_position_setting'),
												scale = 0.8,
												label_scale = 0.8 * 0.5,
												ref_table = SystemClock.config,
												ref_value = 'clockY',
												w = 4,
												min = -3,
												max = 13,
												step = 0.01,
												decimal_places = 2,
												callback = 'sysclock_set_position_y'
											})
										}
									}
								}
							}
						},
					}
				}
			},
			{
				n = G.UIT.C,
				config = {align = 'tr', minw = 5.5, id = 'sysclock_config_column_right'},
				nodes = {
					{
						n = G.UIT.R,
						config = {align = 'cr', padding = 0},
						nodes = {
							create_option_cycle({
								label = localize('sysclock_size_setting'),
								scale = 0.8,
								w = 4.5,
								options = SystemClock.FONT_SIZES,
								current_option = SystemClock.config.clockTextSizeIndex,
								opt_callback = 'sysclock_change_clock_size',
								colour = G.C.GREEN
							})
						}
					},
					{
						n = G.UIT.R,
						config = {align = 'cr', padding = 0},
						nodes = {
							create_option_cycle({
								label = localize('sysclock_style_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_styles'),
								current_option = SystemClock.config.clockStyleIndex,
								opt_callback = 'sysclock_change_clock_style',
								colour = G.C.ORANGE
							})
						}
					},
					{
						n = G.UIT.R,
						config = {align = 'cr', padding = 0},
						nodes = {
							create_option_cycle({
								label = localize('sysclock_text_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_colours'),
								current_option = SystemClock.config.clockColourIndex,
								opt_callback = 'sysclock_change_clock_colour',
								colour = G.C.BLUE
							})
						}
					},
					{
						n = G.UIT.R,
						config = {align = 'cr', padding = 0},
						nodes = {
							create_option_cycle({
								label = localize('sysclock_back_colour_setting'),
								scale = 0.8,
								w = 4.5,
								options = localize('sysclock_colours'),
								current_option = SystemClock.config.clockBackColourIndex,
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
