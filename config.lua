SystemClock.config = {}
SystemClock.CONFIG_DEFAULTS = {
	['config_version'] = 4,
	['clock_visible'] = true,
	['clock_allow_drag'] = true,
	['hour_offset'] = 0,
	['clock_preset_index'] = 1,
	['clock_presets'] = {
		[1] = {
			['format'] = 4,
			['style'] = 5,
			['size'] = 0.6,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 0.44356,
				['y'] = -0.65719
			}
		},
		[2] = {
			['format'] = 1,
			['style'] = 2,
			['size'] = 0.4,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'GREEN'
			},
			['position'] = {
				['x'] = -0.45227,
				['y'] = 11.55784
			}
		},
		[3] = {
			['format'] = 6,
			['style'] = 1,
			['size'] = 0.3,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 13.51127,
				['y'] = 2.50993
			}
		},
		[4] = {
			['format'] = 1,
			['style'] = 3,
			['size'] = 0.5,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 17.52411,
				['y'] = 7.88492
			}
		},
		[5] = {
			['format'] = 2,
			['style'] = 1,
			['size'] = 0.3,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 17.34843,
				['y'] = 11.39360
			}
		}
	}
}
local SAVE_FILE_NAME = 'SystemClock_v4.jkr'
local SAVE_DIR = 'config'
local SAVE_PATH = SAVE_DIR .. '/' .. SAVE_FILE_NAME


function SystemClock.save_config()
	if not love.filesystem.getInfo(SAVE_DIR) then
        sendInfoMessage("Creating config folder...", "SystemClock")
        local success = love.filesystem.createDirectory(SAVE_DIR)
		if not success then
			sendErrorMessage("Failed to create config folder", "SystemClock")
		end
    end

	local success, err = love.filesystem.write(
		'config/' .. SAVE_FILE_NAME, 
		'return ' .. SystemClock.table_to_string(SystemClock.config or SystemClock.CONFIG_DEFAULTS)
	)
    if not success then
        sendErrorMessage("Failed to save config file: " .. err, 'SystemClock')
    end
end


function SystemClock.load_config()
	local loaded_config = {}
	if love.filesystem.getInfo(SAVE_PATH) then
		local config_contents, read_err = love.filesystem.read(SAVE_PATH)
		if not config_contents then
			sendErrorMessage("Failed to read config file: " .. read_err, 'SystemClock')
		else
			local success, load_err = pcall(function()
				loaded_config = load(config_contents, 'systemclock_load_config')()
			end)
			if not success then
				sendErrorMessage("Error loading existing config file: " .. load_err, 'SystemClock')
			end
		end
	end

	SystemClock.config = SystemClock.table_deep_copy(SystemClock.CONFIG_DEFAULTS, loaded_config)
	SystemClock.update_config_version()

	return SystemClock.config
end


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


return SystemClock.CONFIG_DEFAULTS