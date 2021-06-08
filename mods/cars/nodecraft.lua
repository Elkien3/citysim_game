local function do_copy(data, param2data, dim, offset, stride)
	local my_schematic = {
		size = dim,
		data = {}
	}
	for z = 0, dim.z-1 do
		local src_index_z = (offset.z + z) * stride.z + 1 -- +1 for 1-based indexing
		for y = 0, dim.y-1 do
			local src_index_y = src_index_z + (offset.y + y) * stride.y
			-- Copy entire row at once
			local src_index_x = src_index_y + offset.x
			for x = 0, dim.x-1 do
				local nodetable = {name = minetest.get_name_from_content_id(data[src_index_x + x]), prob = 254, param2 = param2data[src_index_x + x]}
				table.insert(my_schematic.data, nodetable)
			end
		end
	end
	return my_schematic
end

local mh = worldedit.manip_helpers

function make_luaschem(pos1, pos2)
	local pos1, pos2 = worldedit.sort_pos(pos1, pos2)

	local manip, area = mh.init(pos1, pos2)
	local stride = {x=1, y=area.ystride, z=area.zstride}
	local offset = vector.subtract(pos1, area.MinEdge)
	local dim = vector.add(vector.subtract(pos2, pos1), 1)

	-- Copy node data
	local data = manip:get_data()
	local param2data = manip:get_param2_data()
	return do_copy(data, param2data, dim, offset, stride)
end

function read_schem(name)
	local path = minetest.get_modpath("cars") .. "/schems/" .. name .. ".mts"
	return minetest.read_schematic(path, {}) or nil
end

function schems_match(schem1, schem2)
	if not vector.equals(schem1.size, schem2.size) then return false end
	if #schem1.data ~= #schem2.data then return false end
	for i = 1, #schem1.data do
		if schem1.data[i].name ~= schem2.data[i].name then return false end
		if schem1.data[i].name ~= "air" and schem1.data[i].param2 ~= schem2.data[i].param2 and not vector.equals(minetest.facedir_to_dir(schem1.data[i].param2), minetest.facedir_to_dir(schem2.data[i].param2)) then minetest.chat_send_all(schem1.data[i].name.." "..schem1.data[i].param2.." "..schem2.data[i].param2) return false end
	end
	return true
end

local search_radius = 1

minetest.register_tool("cars:welding_torch", {
    description = "Welding Torch",
    inventory_image = "default_torch.png",
	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing.under then return end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local pos1 = vector.subtract(pos, search_radius)
		local pos2 = vector.add(pos, search_radius)
		local nodes = minetest.find_nodes_in_area(pos1, pos2, {"bones:bones"})
		for nodeid, nodepos in pairs(nodes) do
			node = minetest.get_node(nodepos)
			for carname, def in pairs(cars_registered_cars) do
				if not def.craftschems then goto next end
				local schematics = {}
				for i, schemname in pairs(def.craftschems) do
					table.insert(schematics, read_schem(schemname) or nil)
				end
				for schemid, schem in pairs(schematics) do
					for dataid, data in pairs(schem.data) do
						if data.name == node.name then
							local size = vector.subtract(schem.size, 1)
							local area = VoxelArea:new{MinEdge = {x=0,y=0,z=0}, MaxEdge = size}
							local offset = area:position(dataid)
							local worldschem = make_luaschem(vector.subtract(nodepos, offset), vector.add(vector.subtract(nodepos, offset), size))
							if schems_match(schem, worldschem) then
								worldedit.set(vector.subtract(nodepos, offset), vector.add(vector.subtract(nodepos, offset), size), "air")
								local ent = minetest.add_entity(vector.add(vector.subtract(nodepos, offset), vector.multiply(size, .5)), carname, user:get_player_name())
								ent:setyaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2))-math.pi)
								return
							end
						end
					end
				end
				::next::
			end
		end
	end,
})