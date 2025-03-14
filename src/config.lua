local config = {}

local logger = require('systemclock.logger')
local utilities = require('systemclock.utilities')

local DEFAULTS = {
	['config_version'] = 5,
	['clock_visible'] = true,
	['clock_persistent'] = true,
	['clock_right_click_tutorial'] = true,
	['clock_allow_drag'] = true,
	['clock_preset_index'] = 1,
	['clock_presets'] = {
		[1] = {
			['format'] = 4,
			['style'] = 'panel',
			['size'] = 0.5,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 0.580,
				['y'] = -0.622
			}
		},
		[2] = {
			['format'] = 5,
			['style'] = 'emboss',
			['size'] = 0.4,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'GREEN'
			},
			['position'] = {
				['x'] = -0.382,
				['y'] = 11.653
			}
		},
		[3] = {
			['format'] = 6,
			['style'] = 'simple',
			['size'] = 0.3,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 13.660,
				['y'] = 2.660
			}
		},
		[4] = {
			['format'] = 1,
			['style'] = 'translucent',
			['size'] = 0.5,
			['colours'] = {
				['text'] = 'WHITE',
				['back'] = 'DYN_UI.MAIN'
			},
			['position'] = {
				['x'] = 17.574,
				['y'] = 8.035
			}
		},
		[5] = {
			['format'] = 3,
			['style'] = 'throwback',
			['size'] = 0.6,
			['colours'] = {
				['text'] = 'ORANGE',
				['back'] = 'DYN_UI.BOSS_MAIN'
			},
			['position'] = {
				['x'] = 2.936,
				['y'] = 10.394
			}
		}
	}
}

local SAVE_FILE_NAME = 'SystemClock.jkr'
local SAVE_DIR = 'config'
local SAVE_PATH = SAVE_DIR .. '/' .. SAVE_FILE_NAME

local function serialize_config(tbl, indent)
	indent = indent or 1
	local str = "{\n"

	local function v_to_str(v, indent)
		if (type(v) == 'table') then
			return serialize_config(v, indent + 1)
		elseif (type(v) == 'number' or type(v) == 'boolean') then
			return tostring(v)
		else
			return "\'" .. tostring(v) .. "\'"
		end
	end

	for k, v in ipairs(tbl) do
		if type(v) ~= 'function' then
			str = str .. string.rep("\t", indent) .. "[" .. tostring(k) .. "] = " .. v_to_str(v, indent) .. ",\n"
		end
	end

	for k, v in pairs(tbl) do
		if type(k) == 'string' and type(v) ~= 'function' then
			str = str .. string.rep("\t", indent)
			str = str .. "[\'" .. tostring(k) .. "\'] = "
			str = str .. v_to_str(v, indent) .. ",\n"
		end
	end

	str = str .. string.rep("\t", indent - 1) .. "}"
	return str
end

function config.save()
	if not love.filesystem.getInfo(SAVE_DIR) then
		logger.log_info("Creating config folder...")
		local success = love.filesystem.createDirectory(SAVE_DIR)
		if not success then
			logger.log_error("Failed to create config folder")
		end
	end

	local success, err = love.filesystem.write(
		'config/' .. SAVE_FILE_NAME,
		'return ' .. serialize_config(config or config.DEFAULTS)
	)
	if not success then
		logger.log_error("Failed to save config file: " .. err)
	end
end

local function update_config_version()
	if not config then
		logger.log_error("Config not loaded")
		return
	end

	if config.clockColourIndex then
		logger.log_info("Transferring config settings (v1 -> v2)")
		config.clockTextColourRef = SystemClock.COLOUR_REFS[config.clockColourIndex]
		config.clockTextColourIndex = config.clockColourIndex
		config.clockBackColourRef = 'DYN_UI.MAIN'
		config.clockColourIndex = nil
		config.clockColour = nil

		config.clockConfigVersion = 2
	end

	if config.clockConfigVersion == 2 then
		logger.log_info("Transferring config settings (v2 -> v4)")
		config.clock_presets[5].format = config.clockTimeFormatIndex
		config.clock_presets[5].style = config.clockStyleIndex
		config.clock_presets[5].size = config.clockTextSize
		config.clock_presets[5].colours.text = config.clockTextColourRef
		config.clock_presets[5].colours.back = config.clockBackColourRef
		config.clock_presets[5].position.x = config.clockX
		config.clock_presets[5].position.y = config.clockY
		config.clock_preset_index = 5
		config.clock_visible = config.clockVisible
		config.clock_allow_drag = config.clockAllowDrag
		config.hour_offset = config.hourOffset

		config.clockTimeFormatIndex = nil
		config.clockStyleIndex = nil
		config.clockTextColourIndex = nil
		config.clockTextColourRef = nil
		config.clockBackColourIndex = nil
		config.clockBackColourRef = nil
		config.clockTextSize = nil
		config.clockTextSizeIndex = nil
		config.clockX = nil
		config.clockY = nil
		config.clockVisible = nil
		config.clockAllowDrag = nil
		config.hourOffset = nil
		config.clockConfigVersion = nil

		config.config_version = 4
	end

	if config.clockConfigVersion == 3 then
		logger.log_info("Transferring config settings (v3 -> v4)")
		config.clock_visible = config.clockVisible
		config.clock_allow_drag = config.clockAllowDrag
		config.hour_offset = config.hourOffset
		config.clock_preset_index = config.clockPresetIndex
		config.clock_presets = config.clockPresets

		config.clockVisible = nil
		config.clockAllowDrag = nil
		config.hourOffset = nil
		config.clockPresetIndex = nil
		config.clockPresets = nil
		config.clockConfigVersion = nil

		config.config_version = 4
	end

	if config.config_version == 4 then
		logger.log_info("Transferring config settings (v4 -> v5)")

		local v4_style_names = { 'simple', 'shadow', 'translucent', 'panel', 'emboss', 'throwback' }
		for _, preset in ipairs(config.clock_presets) do
			local style_index = preset.style
			preset.style = v4_style_names[style_index] or 'simple'
			if preset.position then
				preset.position.x = preset.position.x + 0.13
				preset.position.y = preset.position.y + 0.15
			end
		end
		config.config_version = 5
	end

	config.save()
end

function config.load()
	local loaded_config = {}
	if love.filesystem.getInfo(SAVE_PATH) then
		local config_contents, read_err = love.filesystem.read(SAVE_PATH)
		if not config_contents then
			logger.log_error("Failed to read config file: " .. read_err)
		else
			local success, load_err = pcall(function()
				loaded_config = load(config_contents, 'systemclock_load_config')()
			end)
			if not success then
				logger.log_error("Error loading existing config file: " .. load_err)
			end
		end
	end

	utilities.deep_merge(loaded_config, config)
	utilities.deep_merge(DEFAULTS, config)

	update_config_version()

	return config
end

function config.reset_preset(preset_index)
	config.clock_presets[preset_index] = utilities.deep_copy(DEFAULTS.clock_presets[preset_index])
	config.save()
end

function config.get_preset_default(preset_index)
	return DEFAULTS.clock_presets[preset_index]
end

return config
