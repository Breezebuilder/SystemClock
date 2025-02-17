function SystemClock.index_of(table, val)
	if not val then return nil end
	for i, v in ipairs(table) do
		if v == val then return i end
	end
	return nil
end


function SystemClock.table_to_string(tbl, indent)
	indent = indent or 1
	local str = "{\n"

    local function v_to_str(v, indent)
        if (type(v) == 'table') then return SystemClock.table_to_string(v, indent + 1)
        elseif (type(v) == 'number' or type(v) == 'boolean') then return tostring(v)
        else return "\'" .. tostring(v) .. "\'"
        end
    end

	for k, v in ipairs(tbl) do
		str = str .. string.rep("\t", indent) .. "[" .. tostring(k) .. "] = " .. v_to_str(v, indent)  .. ",\n"
	end

    for k, v in pairs(tbl) do
        if type(k) == 'string' then
            str = str .. string.rep("\t", indent)
            str = str .. "[\'" .. tostring(k) .. "\'] = "
            str = str .. v_to_str(v, indent) .. ",\n"
        end
    end

	str = str .. string.rep("\t", indent - 1) .. "}"
	return str
end


function SystemClock.table_deep_copy(source, destination, replace)
    for k, v in pairs(source) do
        if type(v) == 'table' then
            if replace or destination[k] == nil then
                destination[k] = {}
            end
            SystemClock.table_deep_copy(v, destination[k], replace)
        else
            if replace or destination[k] == nil then
                destination[k] = v
            end
        end
    end
    return destination
end


function SystemClock.get_colour_from_ref(ref)
	if not ref then return nil end

	local depth = 0
	local colour = G.C
	for obj_name in ref:gmatch("[^%.]+") do
		colour = colour[obj_name]
		depth = depth + 1
		if depth > 2 or not colour then
			return nil
		end
	end
	return type(colour) == 'table' and colour
end