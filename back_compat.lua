function SystemClock.update_config_version()
	if SystemClock.config.clockColourIndex then
		sendInfoMessage("Transferring config settings (v1 -> v2)", 'SystemClock')
		SystemClock.config.clockTextColourRef = SystemClock.COLOUR_REFS[SystemClock.config.clockColourIndex]
		SystemClock.config.clockTextColourIndex = SystemClock.config.clockColourIndex
		SystemClock.config.clockBackColourRef = 'DYN_UI.MAIN'
		SystemClock.config.clockColourIndex = nil
		SystemClock.config.clockColour = nil

		SystemClock.config.clockConfigVersion = 2
	end

	if SystemClock.config.clockConfigVersion == 2 then
		sendInfoMessage("Transferring config settings (v2 -> v4)", 'SystemClock')
		SystemClock.config.clock_presets[5].format = SystemClock.config.clockTimeFormatIndex
		SystemClock.config.clock_presets[5].style = SystemClock.config.clockStyleIndex
		SystemClock.config.clock_presets[5].size = SystemClock.config.clockTextSize
		SystemClock.config.clock_presets[5].colours.text = SystemClock.config.clockTextColourRef
		SystemClock.config.clock_presets[5].colours.back = SystemClock.config.clockBackColourRef
		SystemClock.config.clock_presets[5].position.x = SystemClock.config.clockX
		SystemClock.config.clock_presets[5].position.y = SystemClock.config.clockY
        SystemClock.config.clock_preset_index = 5
        SystemClock.config.clock_visible = SystemClock.config.clockVisible
		SystemClock.config.clock_allow_drag = SystemClock.config.clockAllowDrag
		SystemClock.config.hour_offset = SystemClock.config.hourOffset

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
        SystemClock.config.clockVisible = nil
		SystemClock.config.clockAllowDrag = nil
		SystemClock.config.hourOffset = nil
        SystemClock.config.clockConfigVersion = nil

		SystemClock.config.config_version = 4
	end

	if SystemClock.config.clockConfigVersion == 3 then
		sendInfoMessage("Transferring config settings (v3 -> v4)", 'SystemClock')
		SystemClock.config.clock_visible = SystemClock.config.clockVisible
		SystemClock.config.clock_allow_drag = SystemClock.config.clockAllowDrag
		SystemClock.config.hour_offset = SystemClock.config.hourOffset
		SystemClock.config.clock_preset_index = SystemClock.config.clockPresetIndex
        SystemClock.config.clock_presets = SystemClock.config.clockPresets

		SystemClock.config.clockVisible = nil
		SystemClock.config.clockAllowDrag = nil
		SystemClock.config.hourOffset = nil
		SystemClock.config.clockPresetIndex = nil
        SystemClock.config.clockPresets = nil
        SystemClock.config.clockConfigVersion = nil

		SystemClock.config.config_version = 4
	end

    SystemClock.save_config()
end