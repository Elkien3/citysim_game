waterworks = {}

local modpath = minetest.get_modpath(minetest.get_current_modname()) 

waterworks.registered_liquids = {}
waterworks.register_liquid = function(name, def)
	if not def then def = {} else
		if not def.replace then
			minetest.override_item(name, {liquid_renewable = false})
			if def.flowing then
				minetest.override_item(def.flowing, {liquid_renewable = false})
			end
		end
	end
	waterworks.registered_liquids[name] = def
end

waterworks.register_liquid("default:water_source", {flowing = "default:water_flowing"})

dofile(modpath .. "/globalstep.lua")
dofile(modpath .. "/network.lua")
dofile(modpath .. "/execute.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/crafting.lua")

-- This rebuilds pipe networks whenever the map block is loaded.
-- May be useful for fixing broken stuff.
-- Note that this doesn't *remove* pipes that are inappropriately listed in the network,
-- that may be tricky.
--minetest.register_lbm({
--    label = "Validate waterworks pipe networks",
--    name = "waterworks:validate_pipe_networks",
--    nodenames = {"group:waterworks_pipe"},
--    run_at_every_load = true,
--    action = function(pos, node)
--		local hash_pos = minetest.hash_node_position(pos)
--		local found = false
--		for i, net in ipairs(waterworks.pipe_networks) do
--			if net.pipes[hash_pos] then
--				found = true
--				break
--			end
--		end
--		if not found then
--			local new_net_index = waterworks.place_pipe(pos)
--			minetest.log("warning", "[waterworks] detected an unregistered pipe at " ..
--				minetest.pos_to_string(pos) .. ", added it to pipe network " ..
--				tostring(new_net_index))
--		end
--	end,
--})

--minetest.register_chatcommand("dump_pipes", {
----    params = "pos", -- Short parameter description
--    description = "dump pipe network to debug log",
--    func = function(name, param)
--		--minetest.debug(dump(pipe_networks))
--		
--		for i, net in ipairs(waterworks.pipe_networks) do
--			minetest.debug("net #" .. tostring(i) .. " cache valid: " .. dump(net.cache_valid))
--			minetest.debug("\tpipes:")
--			local count = 0
--			for hash_pos, _ in pairs(net.pipes) do
--				minetest.debug("\t\t"..minetest.pos_to_string(minetest.get_position_from_hash(hash_pos)))
--				count = count + 1
--			end
--			minetest.debug("\tpipe count: " .. tostring(count))
--			minetest.debug("\tconnections:")
--			for connection_type, connection_list in pairs(net.connected) do
--				minetest.debug("\t\t"..connection_type..":")
--				for connection_hash, data in pairs(connection_list) do
--					minetest.debug("\t\t\t"..minetest.pos_to_string(minetest.get_position_from_hash(connection_hash))..": "..string.gsub(string.gsub(dump(data), "\t", ""), "\n", " "))
--				end
--			end
--		end
--		
--	end,
--})
