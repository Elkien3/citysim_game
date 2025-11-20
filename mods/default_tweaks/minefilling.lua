local forceremovetbl = {}
local fill_limit = -50

--this tweak was not tested with large multiplayer use, so it may or may not be included based on effect on multiplayer world
--it also adds (very little) meta to ALL blocks placed in natural caves.
--[[
local orig_func = minetest.remove_node
function minetest.remove_node(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local f = meta:get_int("f")
	local val = orig_func(pos)
	if pos.y < fill_limit then
		local hash = minetest.hash_node_position(pos)
		if forceremovetbl[hash] then
			forceremovetbl[hash] = nil
		--[[elseif node.name == "walking_light:light" or node.name == "technic:light" or string.find(node.name, "beamlight:light") then --keep lights from making a ton of tunnel fillers
			local pos1 = vector.subtract(pos, 1)
			local pos2 = vector.add(pos, 1)
			local nodes = minetest.find_nodes_in_area(pos1, pos2, {"default_tweaks:tunnel_filler"})
			if #nodes > 1 then--possible issue: dig one block, point light at to remove the tunnel filler, then repeat to make nonfilling tunnel. perhaps save meta in the light node if it needs to be filled or not. might need this for water too
				minetest.set_node(pos, {name = "default_tweaks:tunnel_filler"})
			end--]]
		elseif f == 0 then
			minetest.set_node(pos, {name = "default_tweaks:tunnel_filler"})
		end
	end
	return val
end
--]]
--todo: could make the filling sediment harden under pressure (when surrounded by all sides) into the biome stone
local function get_biome_stone(pos)
	local biomeid = minetest.get_biome_data(pos).biome
	local biomename = minetest.get_biome_name(biomeid)
	return minetest.registered_biomes[biomename].node_stone or "default:stone"
end
--[[
local orig_func2 = minetest.set_node
function minetest.add_node(pos, node)
	local oldnode = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local f = meta:get_int("f")
	local val = orig_func2(pos, node)
	if pos.y < fill_limit then
		if node.name == "air" and f == 0 then
			minetest.set_node(pos, {name = "default_tweaks:tunnel_filler"})
		elseif oldnode.name == "air" and node.name ~= "default_tweaks:tunnel_filler" then
			meta:set_int("f", 1)
		end
	end
	return val
end
minetest.set_node = minetest.add_node
--]]
minetest.register_node("default_tweaks:tunnel_filler", {
	description = "Tunnel Filler",
	groups = {not_in_creative_inventory = 1, light_replaceable = 1},
	drawtype = "airlike",
	--drawtype = "glasslike",
	--tiles = {"default_glass.png"},
	--use_texture_alpha = true,
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	floodable = true,
	on_blast = function(pos, intensity) return end,
})

minetest.register_lbm({
    label = "Yeet tunnel filler"
    name = "default_tweaks:filleryeet",
    nodenames = {"default_tweaks:tunnel_filler"},
    run_at_every_load = false,
    action = function(pos, node, dtime_s)
		minetest.remove_node(pos)
	end
})

minetest.register_on_liquid_transformed(function(pos_list, node_list)
	for i, pos in pairs(pos_list) do
		if pos.y < fill_limit then
			local node = node_list[i]
			if minetest.get_item_group(node.name, "liquid") > 0 then--its water being replaced by air, place tunnel filler unless it has the "f" exception
				local meta = minetest.get_meta(pos)
				local newnode = minetest.get_node(pos)
				if newnode.name == "air" and meta:get_int("f") == 0 then
					minetest.set_node(pos, {name = "default_tweaks:tunnel_filler"})
				end
			elseif node.name == "air" then --if its air being replaced by water, add the exception
				local newnode = minetest.get_node(pos)
				if minetest.get_item_group(newnode.name, "liquid") > 0 then
					local meta = minetest.get_meta(pos)
					meta:set_int("f", 1)
				end
			end
		end
	end
end)
--[[
minetest.register_abm({
	label = "Tunnel Filling",
	nodenames = {"default_tweaks:tunnel_filler"},
	neighbors = {"default:stone", "default:gravel", "default:sandstone", "default:silver_sandstone"},
	interval = 3600,--every hour one in 1000 blocks are filled up, every block should fill up in abt 1 irl month
	chance = 1000,
	min_y = -32768,
	max_y = fill_limit,
	catch_up = true,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pos1 = vector.subtract(pos, 1)
		local pos2 = vector.add(pos, 1)
		local biomestone = get_biome_stone(pos)
		local nodes = minetest.find_nodes_in_area(pos1, pos2, {"default_tweaks:tunnel_filler", "default:gravel", biomestone})
		if #nodes < 18 then
			if math.random(3) == 1 then
				local hash = minetest.hash_node_position(pos)
				forceremovetbl[hash] = true
				minetest.remove_node(pos)
			end
			return
		end
		local airnodes = minetest.find_nodes_in_area(pos1, pos2, {"air"})
		if #airnodes > 8 then
			if math.random(3) == 1 then
				local hash = minetest.hash_node_position(pos)
				forceremovetbl[hash] = true
				minetest.remove_node(pos)
			end
			return
		end
		local stone_tbl = {
			["default:stone"] = "default:gravel",
			["default:sandstone"] = "default:sand",
			["default:desert_stone"] = "default:desert_sand",
			["default:silver_sandstone"] = "default:silver_sand"
		}
		minetest.set_node(pos, {name = (stone_tbl[biomestone] or "default:gravel")})
		minetest.check_single_for_falling(pos)
	end,
})--]]