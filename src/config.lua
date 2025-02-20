local config = {}

local utilities = require('systemclock.utilities')

local DEFAULTS = {
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

local SAVE_FILE_NAME = 'SystemClock.jkr'
local SAVE_DIR = 'config'
local SAVE_PATH = SAVE_DIR .. '/' .. SAVE_FILE_NAME


local function serialize_config(tbl, indent)
	indent = indent or 1
	local str = "{\n"

    local function v_to_str(v, indent)
        if (type(v) == 'table') then return serialize_config(v, indent + 1)
        elseif (type(v) == 'number' or type(v) == 'boolean') then return tostring(v)
        else return "\'" .. tostring(v) .. "\'"
        end
    end

	for k, v in ipairs(tbl) do
		if type(v) ~= 'function' then
			str = str .. string.rep("\t", indent) .. "[" .. tostring(k) .. "] = " .. v_to_str(v, indent)  .. ",\n"
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
        sendInfoMessage("Creating config folder...", "SystemClock")
        local success = love.filesystem.createDirectory(SAVE_DIR)
		if not success then
			sendErrorMessage("Failed to create config folder", "SystemClock")
		end
    end

	local success, err = love.filesystem.write(
		'config/' .. SAVE_FILE_NAME, 
		'return ' .. serialize_config(config or config.DEFAULTS)
	)
    if not success then
        sendErrorMessage("Failed to save config file: " .. err, 'SystemClock')
    end
end


local function update_config_version()
	if not config then
		sendErrorMessage("Config not loaded", 'SystemClock')
		return
	end

	if config.clockColourIndex then
		sendInfoMessage("Transferring config settings (v1 -> v2)", 'SystemClock')
		config.clockTextColourRef = SystemClock.COLOUR_REFS[config.clockColourIndex]
		config.clockTextColourIndex = config.clockColourIndex
		config.clockBackColourRef = 'DYN_UI.MAIN'
		config.clockColourIndex = nil
		config.clockColour = nil

		config.clockConfigVersion = 2
	end

	if config.clockConfigVersion == 2 then
		sendInfoMessage("Transferring config settings (v2 -> v4)", 'SystemClock')
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
		sendInfoMessage("Transferring config settings (v3 -> v4)", 'SystemClock')
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

    config.save()
end


function config.load()
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

	utilities.table_deep_merge(DEFAULTS, config)
	utilities.table_deep_merge(loaded_config, config, true)

	update_config_version()

	return config
end


function config.reset_preset(preset_index)
	config.clock_presets[preset_index] = utilities.table_deep_copy(DEFAULTS.clock_presets[preset_index])
	config.save()
end

return config