SMODS.current_mod.config_tab = function()
	return {
		n = G.UIT.ROOT,
		config = {
			r = 0.1,
			minh = 5,
			minw = 6,
			align = 'tm',
			padding = 0.0,
			colour = G.C.CLEAR
		},
		nodes = {{
			n = G.UIT.R,
			config = {
				padding = 0.05
			},
			nodes = {{
				n = G.UIT.C,
				config = {
					align = 'cm'
				},
				nodes = {create_toggle({
					label = localize('sysclock_visibility_setting'),
					scale = 0.8,
					ref_table = SystemClock.config,
					ref_value = 'clockVisible',
					callback = SystemClock.reset_clock_ui
				}), create_toggle({
					label = localize('sysclock_draggable_setting'),
					scale = 0.8,
					ref_table = SystemClock.config,
					ref_value = 'clockAllowDrag',
					callback = SystemClock.reset_clock_ui
				}), create_option_cycle({
					label = localize('sysclock_time_format_setting'),
					scale = 0.8,
					w = 4.5,
					options = SystemClock.EXAMPLE_FORMATS,
					current_option = SystemClock.config.clockTimeFormatIndex,
					opt_callback = 'sysclock_change_clock_time_format'
				}), create_option_cycle({
					label = localize('sysclock_style_setting'),
					scale = 0.8,
					w = 4.5,
					options = localize('sysclock_styles'),
					current_option = SystemClock.config.clockStyleIndex,
					opt_callback = 'sysclock_change_clock_style'
				}), create_option_cycle({
					label = localize('sysclock_colour_setting'),
					scale = 0.8,
					w = 4.5,
					options = localize('sysclock_colours'),
					current_option = SystemClock.config.clockColourIndex,
					opt_callback = 'sysclock_change_clock_colour'
				}), create_option_cycle({
					label = localize('sysclock_size_setting'),
					scale = 0.8,
					w = 4.5,
					options = SystemClock.FONT_SIZES,
					current_option = SystemClock.config.clockTextSizeIndex,
					opt_callback = 'sysclock_change_clock_size'
				}), create_slider({
					label = localize('sysclock_x_position_setting'),
					scale = 0.8,
					label_scale = 0.8 * 0.5,
					ref_table = SystemClock.config,
					ref_value = 'clockX',
					w = 4.5,
					min = -3,
					max = 21,
					step = 0.01,
					decimal_places = 2,
					callback = 'sysclock_set_position_x'
				}), create_slider({
					label = localize('sysclock_y_position_setting'),
					scale = 0.8,
					label_scale = 0.8 * 0.5,
					ref_table = SystemClock.config,
					ref_value = 'clockY',
					w = 4.5,
					min = -2,
					max = 12,
					step = 0.01,
					decimal_places = 2,
					callback = 'sysclock_set_position_y'
				})}
			}}
		}}
	}
end
