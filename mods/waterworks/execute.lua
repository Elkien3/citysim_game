local pressure_margin = 20

local pipe_cache = {}

local cardinal_dirs = {
	{x= 0, y=0,  z= 1},
	{x= 1, y=0,  z= 0},
	{x= 0, y=0,  z=-1},
	{x=-1, y=0,  z= 0},
	{x= 0, y=-1, z= 0},
	{x= 0, y=1,  z= 0},
}

local sort_by_pressure = function(first, second)
	local first_pressure = first.pressure
	local second_pressure = second.pressure
	if first_pressure == nil or second_pressure == nil then
		minetest.log("error", "[waterworks] attempted to sort something by pressure that had no pressure value: " .. dump(first) .. "\n" .. dump(second))
		return
	end
	
	return first_pressure > second_pressure
end

local valid_sink = function(node_name)
	return node_name == "air" or node_name == "default:water_flowing" or node_name == "static_ocean:water_flowing"
end
local valid_source = function(node_name)
	return waterworks.registered_liquids[node_name] ~= nil
end

-- breadth-first search passing through water searching for air or flowing water, limited to y <= pressure.
-- I could try to be fancy about water flowing downward preferentially, let's leave that as a TODO for now.
local flood_search_outlet = function(start_pos, pressure)
	local start_node =  minetest.get_node(start_pos)
	local start_node_name = start_node.name
	if valid_sink(start_node_name) then
		return start_pos
	end

	local visited = {}
	visited[minetest.hash_node_position(start_pos)] = true
	local queue = {start_pos}
	local queue_pointer = 1
	
	while #queue >= queue_pointer do
		local current_pos = queue[queue_pointer]		
		queue_pointer = queue_pointer + 1
		for _, cardinal_dir in ipairs(cardinal_dirs) do
			local new_pos = vector.add(current_pos, cardinal_dir)
			local new_hash = minetest.hash_node_position(new_pos)
			if visited[new_hash] == nil and new_pos.y <= pressure then
				local new_node = minetest.get_node(new_pos)
				local new_node_name = new_node.name
				if valid_sink(new_node_name) then
					return new_pos
				end
				visited[new_hash] = true
				if valid_source(new_node_name) then
					table.insert(queue, new_pos)
				end
			end
		end		
	end
	return nil
end


local upward_dirs = {
	{x= 0, y=0,  z= 1},
	{x= 1, y=0,  z= 0},
	{x= 0, y=0,  z=-1},
	{x=-1, y=0,  z= 0},
	{x= 0, y=1,  z= 0},
}

local shuffle = function(tbl)
	for i = #tbl, 2, -1 do
		local rand = math.random(i)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	end
	return tbl
end

-- depth-first random-walk search trending in an upward direction, returns when it gets cornered
local find_source = function(start_pos)
	local current_node =  minetest.get_node(start_pos)	
	local current_node_name = current_node.name
	if not valid_source(current_node_name) then
		return nil
	end

	local visited = {[minetest.hash_node_position(start_pos)] = true}
	local current_pos = start_pos
	
	local continue = true
	while continue do
		continue = false
		shuffle(upward_dirs)
		for _, dir in ipairs(upward_dirs) do
			local next_pos = vector.add(current_pos, dir)
			local next_hash = minetest.hash_node_position(next_pos)
			if visited[next_hash] == nil then
				visited[next_hash] = true
				local next_node = minetest.get_node(next_pos)
				local next_node_name = next_node.name
				if valid_source(next_node_name) then
					current_pos = next_pos
					continue = true
					break
				end
			end
		end
	end
	return current_pos
end


waterworks.execute_pipes = function(net_index, net_capacity)
	local net = waterworks.pipe_networks[net_index]
	if net == nil then
		minetest.log("error", "[waterworks] Invalid net index given to execute: " .. tostring(net_index))
		return
	end

	local inlets
	local outlets
	
	if net.cache_valid and pipe_cache[net_index] then
		-- We don't need to recalculate, nothing about the pipe network has changed since last time
		inlets = pipe_cache[net_index].inlets
		outlets = pipe_cache[net_index].outlets
	else
		-- Find all the inlets and outlets and sort them by pressure
		inlets = {}
		if net.connected.inlet ~= nil then
			for _, inlet_set in pairs(net.connected.inlet) do
				for _, inlet in pairs(inlet_set) do
					table.insert(inlets, inlet)
				end
			end
		end
		table.sort(inlets, sort_by_pressure)
		
		outlets = {}
		if net.connected.outlet ~= nil then 
			for _, outlet_set in pairs(net.connected.outlet) do
				for _, outlet in pairs(outlet_set) do
					table.insert(outlets, outlet)
				end
			end
		end
		table.sort(outlets, sort_by_pressure)
		
		-- Cache the results
		pipe_cache[net_index] = {}
		pipe_cache[net_index].inlets = inlets
		pipe_cache[net_index].outlets = outlets
		
		net.cache_valid = true
	end
	
	local inlet_index = 1
	local outlet_index = #outlets
	local inlet_count = #inlets
	
	local count = 0
	
	-- Starting with the highest-pressure inlet and the lowest-pressure outlet, attempt to move water.
	-- We then proceed to steadily lower-pressure inlets and higher-pressure outlets until we meet in the middle, at which point
	-- the system is in equilibrium.
	while inlet_index <= inlet_count and outlet_index > 0  and count < net_capacity do
		local source = inlets[inlet_index]
		local sink = outlets[outlet_index]
		--sink.target sink.pos sink.pressure
		
		--minetest.debug("source: " .. dump(source))
		--minetest.debug("sink: " .. dump(sink))
		
		-- pressure_margin allows us to check sources that are a little bit below sinks,
		-- in case the extra pressure from their water depth is sufficient to force water through
		if source.pressure + pressure_margin >= sink.pressure then 
			local source_pos = find_source(source.target)
			local sink_pos
			if source_pos ~= nil then
				sink_pos = flood_search_outlet(sink.target, math.max(source.pressure, source_pos.y))
				--if sink_pos ~= nil then
					local source_node = minetest.get_node(source_pos).name
					local source_def = waterworks.registered_liquids[source_node]
					if source_def and source_def.replace then
						source_node = source_def.replace
					end
					if minetest.get_node(sink.pos).name == "thirsty:fountain" then
						if source_node == "thirsty:water_clean_source" then
							local meta = minetest.get_meta(sink.pos)
							local water = meta:get_float("water")
							if water <= 200 then
								meta:set_float("water", water + 200)
								meta:set_string("infotext", "Drinking Fountain "..(water + 200).."L")
								minetest.swap_node(source_pos, {name="air"})
							end
						else
							source_pos = nil
						end
					elseif sink_pos ~= nil then
						minetest.swap_node(sink_pos, {name=source_node})
						minetest.swap_node(source_pos, {name="air"})
					end
					count = count + 1
				--end
			end
			
			if source_pos == nil then
				-- the outlet had available space but the inlet didn't provide
				inlet_index = inlet_index + 1
			elseif sink_pos == nil then
				-- the inlet provided but the outlet didn't have space
				outlet_index = outlet_index - 1
			end
		else
			break
		end
	end	
end
