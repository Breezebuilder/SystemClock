local utilities = {}

function utilities.index_of(table, val)
	if not val then return nil end
	for i, v in ipairs(table) do
		if v == val then return i end
	end
	return nil
end


function utilities.table_deep_merge(source, destination, replace)
    for k, v in pairs(source) do
        if type(v) == 'table' then
            if replace or destination[k] == nil then
                destination[k] = {}
            end
            utilities.table_deep_merge(v, destination[k], replace)
        else
            if replace or destination[k] == nil then
                destination[k] = v
            end
        end
    end
    return destination
end


function utilities.table_deep_copy(source)
    return utilities.table_deep_merge(source, {})
end


function utilities.get_colour_from_ref(ref)
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

return utilities