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

minetest.register_node("cars:engine", {
	description = "Car Engine",
	tiles = {"engine_top.png", "engine_top.png", "engine_side2.png", "engine_side.png", "engine_rear.png", "engine_front.png"},
	paramtype = "light",
	groups = {cracky = 2},
	paramtype2 = "facedir",
})
minetest.register_node("cars:transmission", {
	description = "Car Transmission",
	tiles = {"transmission.png", "transmission.png", "transmission_side.png", "transmission_side.png", "transmission.png", "transmission.png"},
	paramtype = "light",
	groups = {cracky = 2},
	paramtype2 = "facedir",
})
minetest.register_node("cars:seat", {
	description = "Car Seat",
	drawtype = "nodebox",
	tiles = {"wool_black.png", "wool_black.png", "wool_black.png", "wool_black.png", "wool_black.png", "wool_black.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, wool = 1},
	sounds = default.node_sound_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.5, 0.375, -0.3125, 0.5}, -- NodeBox1
			{-0.375, -0.5, 0.3125, 0.375, 0.5, 0.5}, -- NodeBox2
		}
	}
})

minetest.register_node("cars:wheel", {
	description = "Car Wheel",
	tiles = {"wheel_top.png", "wheel_top.png", "wheel_side.png", "wheel_side.png", "wheel_side.png", "wheel_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	groups = {oddly_breakable_by_hand = 3},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	},
})

if minetest.get_modpath("assembler") and minetest.get_modpath("technic") and minetest.get_modpath("mesecons_pistons") then
	minetest.register_craft({
		output = "cars:engine",
		recipe = {
			{"", "moreores:mithril_block", "pipeworks:tube_1", "moreores:mithril_block", ""},
			{"default:obsidian_shard", "mesecons_pistons:piston_normal_off", "pipeworks:tube_1", "", "default:obsidian_shard"},
			{"default:mese_crystal", "", "pipeworks:tube_1", "mesecons_pistons:piston_normal_off", "default:mese_crystal"},
			{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:motor"},
			{"", "", "", "", "technic:lv_battery_box0"}
		}
	})
	minetest.register_craft({
		output = "cars:transmission",
		recipe = {
			{"", "", "", "basic_materials:steel_bar", ""},
			{"", "basic_materials:gear_steel", "basic_materials:steel_bar", "", "technic:control_logic_unit"},
			{"basic_materials:gear_steel", "default:obsidian", "basic_materials:gear_steel", "", "technic:control_logic_unit"},
			{"", "basic_materials:gear_steel", "", "", ""},
			{"basic_materials:steel_bar", "basic_materials:gear_steel", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"}
		}
	})
	minetest.register_craft({
		output = "cars:seat",
		recipe = {
			{"", "group:wool"},
			{"group:wool", "group:wool"},
			{"basic_materials:steel_bar", "basic_materials:steel_bar"}
		}
	})
	minetest.register_craft({
		output = "cars:wheel",
		recipe = {
			{"technic:rubber", "technic:rubber", "technic:rubber"},
			{"technic:rubber", "default:steel_ingot", "technic:rubber"},
			{"technic:rubber", "technic:rubber", "technic:rubber"}
		}
	})
else
	minetest.register_craft({
		output = "cars:engine",
		recipe = {
			{"default:obsidian", "default:mese", "default:copper_ingot"},
			{"", "default:obsidian_shard", "default:copper_ingot"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
		}
	})
	minetest.register_craft({
		output = "cars:transmission",
		recipe = {
			{"", "default:obsidian_shard", ""},
			{"default:obsidian_shard", "default:obsidian", "default:obsidian_shard"},
			{"", "default:obsidian_shard", ""}
		}
	})
	minetest.register_craft({
		output = "cars:seat",
		recipe = {
			{"", "group:wool"},
			{"group:wool", "group:wool"},
			{"default:steel_ingot", "default:steel_ingot"}
		}
	})
	minetest.register_craft({
		output = "cars:wheel",
		recipe = {
			{"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"},
			{"default:obsidian_shard", "default:steel_ingot", "default:obsidian_shard"},
			{"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"}
		}
	})
end