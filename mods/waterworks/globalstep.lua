local worldpath = minetest.get_worldpath()
local network_filename = worldpath.."/waterworks_network.json"

-- Json storage

local save_data = function()
	if waterworks.dirty_data ~= true then
		return
	end
	local file = io.open(network_filename, "w")
	if file then
		file:write(minetest.serialize(waterworks.pipe_networks))
		file:close()
		waterworks.dirty_data = false
	end
end

local read_data = function()
	local file = io.open(network_filename, "r")
	if file then
		waterworks.pipe_networks = minetest.deserialize(file:read("*all")) -- note: any cached references to pipe_networks is invalidated here, so do this once at the beginning of the run and never again thereafter.
		file:close()
	else
		waterworks.pipe_networks = {}
	end
	waterworks.dirty_data = false
	for _, net in ipairs(waterworks.pipe_networks) do
		net.cache_valid = false
	end
end

read_data()

----------------------------------------------

local nets_near_players = {}

minetest.register_abm ({
    label = "Active connected node tracking",
    nodenames = {"group:waterworks_connected"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
		local player_close = false
		for _, player in ipairs(minetest.get_connected_players()) do
			local player_pos = player:get_pos()
			if math.abs(player_pos.x - pos.x) < 161 and math.abs(player_pos.z - pos.z) < 161 and math.abs(player_pos.y - pos.y) < 161 then
				player_close = true
				break
			end			
		end
		
		if not player_close then return end
		
		local hash = minetest.hash_node_position(pos) + waterworks.facedir_to_hash(node.param2)
		local net_index = waterworks.find_network_for_pipe_hash(hash)
		if net_index < 0 then return end
		--minetest.chat_send_all("net near player " .. tostring(net_index))
		nets_near_players[net_index] = 5.0
	end,
})

local forceloads = {}
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 1.0 then
	
		if waterworks.dirty_data then
			-- it's possible that a pipe network was split or merged, invalidating the nets_near_players values here.
			-- Best to clear them and do nothing for one globalstep, they'll be repopulated shortly.
			nets_near_players = {}
		end
		
		-- find connected node positions for all networks with connected nodes near players
		local ensure_forceload = {}
		for index, live_time in pairs(nets_near_players) do
			local new_time = live_time - timer
			--minetest.chat_send_all("new time " .. tostring(new_time))
			if new_time < 0 then
				nets_near_players[index] = nil
			else
				nets_near_players[index] = new_time
				for connection_type, connections in pairs(waterworks.pipe_networks[index].connected) do
					for hash, _ in pairs(connections) do
						ensure_forceload[hash] = true
					end
				end
			end
		end
	
		-- clear forceloads that are no longer needed
		for hash, _ in pairs(forceloads) do
			if not ensure_forceload[hash] then
				minetest.forceload_free_block(minetest.get_position_from_hash(hash), true)
			end
		end
		forceloads = ensure_forceload
		-- enable forceloads that are needed
		for hash, _ in pairs(forceloads) do
			minetest.forceload_block(minetest.get_position_from_hash(hash), true)
		end
	
		timer = timer - 1.0
		save_data()
		for index, _ in pairs(nets_near_players) do
			--minetest.chat_send_all("executing index " .. tostring(index))
			waterworks.execute_pipes(index, 8)
		end
	end
end)

