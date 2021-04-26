local pipe_networks = waterworks.pipe_networks

local invalidate_cache = function(pipe_network)
	pipe_network.cache_valid = false
	waterworks.dirty_data = true
end

local cardinal_dirs = {
	{x= 0, y=0,  z= 1},
	{x= 1, y=0,  z= 0},
	{x= 0, y=0,  z=-1},
	{x=-1, y=0,  z= 0},
	{x= 0, y=-1, z= 0},
	{x= 0, y=1,  z= 0},
}
-- Mapping from facedir value to index in cardinal_dirs.
local facedir_to_dir_map = {
	[0]=1, 2, 3, 4,
	5, 2, 6, 4,
	6, 2, 5, 4,
	1, 5, 3, 6,
	1, 6, 3, 5,
	1, 4, 3, 2,
}

-- Turn the cardinal directions into a set of integers you can add to a hash to step in that direction.
local cardinal_dirs_hash = {}
for i, dir in ipairs(cardinal_dirs) do
	cardinal_dirs_hash[i] = minetest.hash_node_position(dir) - minetest.hash_node_position({x=0, y=0, z=0})
end

local facedir_to_dir_index = function(param2)
	return facedir_to_dir_map[param2 % 32]
end

local facedir_to_cardinal_hash = function(dir_index)
	return cardinal_dirs_hash[dir_index]
end

waterworks.facedir_to_hash = function(param2)
	return facedir_to_cardinal_hash(facedir_to_dir_index(param2))
end

local init_new_network = function(hash_pos)
	waterworks.dirty_data = true
	return {pipes = {[hash_pos] = true}, connected = {}, cache_valid = false}
end

local get_neighbor_pipes = function(pos)
	local neighbor_pipes = {}
	local neighbor_connected = {}
	for _, dir in ipairs(cardinal_dirs) do
		local potential_pipe_pos = vector.add(pos, dir)
		local neighbor = minetest.get_node(potential_pipe_pos)
		if minetest.get_item_group(neighbor.name, "waterworks_pipe") > 0 then
			table.insert(neighbor_pipes, potential_pipe_pos)
		elseif minetest.get_item_group(neighbor.name, "waterworks_connected") > 0 then
			table.insert(neighbor_connected, potential_pipe_pos)
		end
	end
	return neighbor_pipes, neighbor_connected
end

local merge_networks = function(index_list)
	table.sort(index_list)
	local first_index = table.remove(index_list, 1)
	local merged_network = pipe_networks[first_index]
	-- remove in reverse order so that indices of earlier tables to remove don't get disrupted
	for i = #index_list, 1, -1 do
		local index = index_list[i]
		local net_to_merge = pipe_networks[index]
		for pipe_hash, _ in pairs(net_to_merge.pipes) do
			merged_network.pipes[pipe_hash] = true
		end
		for item_type, item_list in pairs(net_to_merge.connected) do
			merged_network.connected[item_type] = merged_network.connected[item_type] or {}
			for connection_hash, connection_data in pairs(item_list) do
				merged_network.connected[item_type][connection_hash] = connection_data
			end
		end
		table.remove(pipe_networks, index)
	end
	invalidate_cache(merged_network)
	return first_index
end

local handle_connected = function(connected_positions)
	for _, pos in ipairs(connected_positions) do
		local node = minetest.get_node(pos)
		local node_def = minetest.registered_nodes[node.name]
		if node_def._waterworks_update_connected then
			node_def._waterworks_update_connected(pos)
		else
			minetest.log("error", "[waterworks] Node def for " .. node.name .. " had no _waterworks_update_connected defined")
		end
	end
end


-- When placing a pipe at pos, identifies what pipe network to add it to and updates the network map.
-- Note that this can result in fusing multiple networks together into one network.
waterworks.place_pipe = function(pos)
	local hash_pos = minetest.hash_node_position(pos)
	local neighbor_pipes, neighbor_connected = get_neighbor_pipes(pos)
	local neighbor_count = #neighbor_pipes
	
	if neighbor_count == 0 then
		-- this newly-placed pipe has no other pipes next to it, so make a new network for it.
		local new_net = init_new_network(hash_pos)
		table.insert(pipe_networks, new_net)
		handle_connected(neighbor_connected)
		return #pipe_networks
	elseif neighbor_count == 1 then
		-- there's only one pipe neighbor. Look up what network it belongs to and add this pipe to it too.
		local neighbor_pos_hash = minetest.hash_node_position(neighbor_pipes[1])
		for i, net in ipairs(pipe_networks) do
			local pipes = net.pipes
			if pipes[neighbor_pos_hash] then
				pipes[hash_pos] = true
				invalidate_cache(net)
				handle_connected(neighbor_connected)
				return i
			end
		end
	else
		local neighbor_index_set = {} -- set of indices for networks that neighbors belong to
		local neighbor_index_list = {} -- list version of above
		for _, neighbor_pos in ipairs(neighbor_pipes) do
			local neighbor_hash = minetest.hash_node_position(neighbor_pos)
			for i, net in ipairs(pipe_networks) do
				if net.pipes[neighbor_hash] then
					if not neighbor_index_set[i] then
						table.insert(neighbor_index_list, i)
						neighbor_index_set[i] = true
					end
				end
			end
		end
		
		if #neighbor_index_list == 1 then -- all neighbors belong to one network. Add this node to that network.
			local target_network_index = neighbor_index_list[1]
			pipe_networks[target_network_index]["pipes"][hash_pos] = true
			invalidate_cache(pipe_networks[target_network_index])
			handle_connected(neighbor_connected)
			return target_network_index
		end
		
		-- The most complicated case, this new pipe segment bridges multiple networks.
		if #neighbor_index_list > 1 then
			local new_index = merge_networks(neighbor_index_list)
			pipe_networks[new_index]["pipes"][hash_pos] = true
			handle_connected(neighbor_connected)
			return new_index
		end
	end
	
	-- if we get here we're in a strange state - there are neighbor pipe nodes but none are registered in a network.
	-- We could be trying to recover from corruption, so pretend the neighbors don't exist and start a new network.
	-- The unregistered neighbors may join it soon.
	local new_net = init_new_network(hash_pos)
	table.insert(pipe_networks, new_net)
	handle_connected(neighbor_connected)
	return #pipe_networks

end

waterworks.remove_pipe = function(pos)
	local hash_pos = minetest.hash_node_position(pos)
	local neighbor_pipes = get_neighbor_pipes(pos)
	local neighbor_count = #neighbor_pipes
		
	if neighbor_count == 0 then
		-- no neighbors, so this is the last of its network.
		for i, net in ipairs(pipe_networks) do
			if net.pipes[hash_pos] then
				table.remove(pipe_networks, i)
				waterworks.dirty_data = true
				return i
			end
		end
		
		minetest.log("error", "[waterworks] pipe removed from pos " .. minetest.pos_to_string(pos) ..
			" didn't belong to any networks. Something went wrong to get to this state.")
		return -1
	elseif neighbor_count == 1 then
		-- there's only one pipe neighbor. This pipe is at the end of a line, so just remove it.
		for i, net in ipairs(pipe_networks) do
			local pipes = net.pipes
			if pipes[hash_pos] then
				pipes[hash_pos] = nil
				invalidate_cache(net)
				-- If there's anything connected to the pipe here, remove it from the network too
				for _, connected_items in pairs(net.connected) do
					connected_items[hash_pos] = nil
				end
				return i
			end
		end
		minetest.log("error", "[waterworks] pipe removed from pos " .. minetest.pos_to_string(pos) ..
			" didn't belong to any networks, despite being neighbor to one at " ..
			minetest.pos_to_string(neighbor_pipes[1]) ..
			". Something went wrong to get to this state.")
		return -1
	else
		-- we may be splitting networks. This is complicated.
		-- find the network we currently belong to. Remove ourselves from it.
		local old_net
		local old_pipes
		local old_connected
		local old_index
		for i, net in ipairs(pipe_networks) do
			local pipes = net.pipes
			if pipes[hash_pos] then
				old_connected = net.connected
				old_net = net
				old_pipes = pipes
				old_index = i
				old_pipes[hash_pos] = nil
				-- if there's anything connected to the pipe here, remove it
				for _, connected_items in pairs(old_connected) do
					connected_items[hash_pos] = nil
				end
			end
		end		
		if old_index == nil then
			minetest.log("error", "[waterworks] pipe removed from pos " .. minetest.pos_to_string(pos) ..
				" didn't belong to any networks, despite being neighbor to several. Something went wrong to get to this state.")
			return -1
		end

		-- get the hashes of the neighbor positions.
		-- We're maintaining a set as well as a list because they're
		-- efficient for different purposes. The list is easy to count,
		-- the set is easy to test membership of.
		local neighbor_hashes_list = {}
		local neighbor_hashes_set = {}
		for i, neighbor_pos in ipairs(neighbor_pipes) do
			local neighbor_hash = minetest.hash_node_position(neighbor_pos)
			neighbor_hashes_list[i] = neighbor_hash
			neighbor_hashes_set[neighbor_hash] = true
		end
		
		-- We're going to need to traverse through the old network, starting from each of our neighbors,
		-- to establish what's still connected.
		local to_visit = {}
		local visited = {[hash_pos] = true} -- set of hashes we've visited already. We know the starting point is not valid.
		local new_nets = {} -- this will be where we put new sets of connected nodes.
		while #neighbor_hashes_list > 0 do
			local current_neighbor = table.remove(neighbor_hashes_list) -- pop neighbor hash and push it into the to_visit list.
			neighbor_hashes_set[current_neighbor] = nil
			table.insert(to_visit, current_neighbor) -- file that neighbor hash as our starting point.
			local new_net = init_new_network(current_neighbor) -- we know that hash is in old_net, so initialize the new_net with it.
			local new_pipes = new_net.pipes
			while #to_visit > 0 do
				local current_hash = table.remove(to_visit)
				for _, cardinal_hash in ipairs(cardinal_dirs_hash) do
					local test_hash = cardinal_hash + current_hash
					if not visited[test_hash] then
						if old_pipes[test_hash] then
							-- we've traversed to a node that was in the old network
							old_pipes[test_hash] = nil -- remove from old network
							new_pipes[test_hash] = true -- add to one we're building
							table.insert(to_visit, test_hash) -- flag it as next one to traverse from
							if neighbor_hashes_set[test_hash] then
								--we've encountered another neighbor while traversing
								--eliminate it from future consideration as a starting point.
								neighbor_hashes_set[test_hash] = nil
								for i, neighbor_hash_in_list in ipairs(neighbor_hashes_list) do
									if neighbor_hash_in_list == test_hash then
										table.remove(neighbor_hashes_list, i)
										break
									end
								end
								if #neighbor_hashes_list == 0 then
									--Huzzah! We encountered all neighbors. The rest of the nodes in old_net should belong to new_net.
									--We can skip all remaining pathfinding flood-fill and connected testing
									for remaining_hash, _ in pairs(old_pipes) do
										new_pipes[remaining_hash] = true
										to_visit = {}
									end
									break
								end
							end
						end
					end
				end
				visited[current_hash] = true
			end
			table.insert(new_nets, new_net)		
		end
		
		-- distribute connected items to the new nets
		if #new_nets == 1 then
			-- net didn't split, just keep the old stuff
			new_nets[1].connected = old_connected
		else
			for _, new_net in ipairs(new_nets) do
				local new_pipes = new_net.pipes
				for item_type, item_list in pairs(old_connected) do
					new_net.connected[item_type] = new_net.connected[item_type] or {}
					for connection_hash, connection_data in pairs(item_list) do
						if new_pipes[connection_hash] then
							new_net.connected[item_type][connection_hash] = connection_data
						end
					end
				end
			end
		end
		
		-- replace the old net with one of the new nets
		pipe_networks[old_index] = table.remove(new_nets)
		-- if there are any additional nets left, add those as brand new ones.
		for _, new_net in ipairs(new_nets) do
			table.insert(pipe_networks, new_net)
		end
		return old_index
	end
end

waterworks.place_connected = function(pos, item_type, data)
	local node = minetest.get_node(pos)
	local dir_index = facedir_to_dir_index(node.param2)
	local dir_hash = facedir_to_cardinal_hash(dir_index)
	local pos_hash = minetest.hash_node_position(pos)
	local connection_hash = pos_hash + dir_hash

	for i, net in ipairs(pipe_networks) do
		if net.pipes[connection_hash] then
			net.connected[item_type] = net.connected[item_type] or {}
			net.connected[item_type][connection_hash] = net.connected[item_type][connection_hash] or {}
			net.connected[item_type][connection_hash][dir_index] = data
			invalidate_cache(net)
			return i
		end
	end
	
	return -1
end

waterworks.remove_connected = function(pos, item_type)
	local node = minetest.get_node(pos)
	local dir_index = facedir_to_dir_index(node.param2)
	local dir_hash = facedir_to_cardinal_hash(dir_index)
	local pos_hash = minetest.hash_node_position(pos)
	local connection_hash = pos_hash + dir_hash
	
	for i, net in ipairs(pipe_networks) do
		if net.pipes[connection_hash] then
			local item_list = net.connected[item_type]
			if item_list then
				if item_list[connection_hash] ~= nil then
					local connected_items = item_list[connection_hash]
					connected_items[dir_index] = nil
					local count = 0
					for _, data in pairs(connected_items) do
						count = count + 1
					end
					if count == 0 then
						item_list[connection_hash] = nil
					end	
					count = 0
					for _, item in pairs(item_list) do
						count = count + 1
					end
					if count == 0 then
						net.connected[item_type] = nil
					end
					invalidate_cache(net)
					return i
				end					
			end
			break -- If we get here, we didn't find the connected node even though we should have.
		end
	end
	
	return -1
end

waterworks.find_network_for_pipe_hash = function(hash)
	for i, net in ipairs(pipe_networks) do
		if net.pipes[hash] then
			return i
		end
	end
	return -1
end