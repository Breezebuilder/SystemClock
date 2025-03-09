local utilities = {}

local DYN_UI_INITIAL_COLOURS = {
	['DYN_UI.MAIN'] = mix_colours(G.C.BLUE, G.C.BLACK, 0.6),
	['DYN_UI.DARK'] = mix_colours(G.C.BLUE, G.C.BLACK, 0.24),
	['DYN_UI.BOSS_MAIN'] = darken(G.C.BLACK, 0.05),
	['DYN_UI.BOSS_DARK'] = lighten(G.C.BLACK, 0.07)
}

function utilities.index_of(table, val)
	if not val then return nil end
	for i, v in ipairs(table) do
		if v == val then return i end
	end

	return nil
end

function utilities.deep_copy(source, destination)
	if type(source) ~= 'table' then return source end

	destination = destination or {}
	if #source > 0 then
		for i, v in ipairs(source) do
			destination[i] = utilities.deep_copy(v)
		end
	else
		for k, v in pairs(source) do
			destination[k] = utilities.deep_copy(v)
		end
	end

	return destination
end

function utilities.deep_merge(source, destination, replace)
	destination = destination or {}

	for k, v in pairs(source) do
		if type(v) == 'table' then
			if replace or destination[k] == nil then
				destination[k] = {}
			end
			utilities.deep_merge(v, destination[k], replace)
		else
			if replace or destination[k] == nil then
				destination[k] = v
			end
		end
	end

	for i, v in ipairs(source) do
		if type(v) == 'table' then
			if replace or destination[i] == nil then
				destination[i] = {}
			end
			utilities.deep_merge(v, destination[i], replace)
		else
			if replace or destination[i] == nil then
				destination[i] = v
			end
		end
	end

	return destination
end


function utilities.shallow_copy(source, destination)
	destination = destination or {}
	for i, v in ipairs(source) do
		destination[i] = v
	end
	return destination
end

function utilities.get_colour_from_ref(ref)
	if not ref then return nil end
	local colour

	if G.STAGE == G.STAGES.MAIN_MENU then
		colour = DYN_UI_INITIAL_COLOURS[ref]
		if colour then return colour end
	end

	colour = G.C
	local depth = 0
	for obj_name in ref:gmatch("[^%.]+") do
		colour = colour[obj_name]
		depth = depth + 1
		if depth > 2 or not colour then
			return { 1, 0, 1, 1 }
		end
	end

	return type(colour) == 'table' and colour or { 1, 0, 1, 1 }
end

return utilities
