local function add_group(name, group, val)
	local defgroup=table.copy(minetest.registered_nodes[name].groups)
	defgroup[group] = val
	minetest.override_item(name, { groups=defgroup })
end

gas_lib.register_gas("gas_lib:smoke", {
	description = 'Smoke',
	tiles = {{
		name = "smoke.png^gui_hb_bg.png",
		--backface_culling=false,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 6,
		},
	}},
	inventory_image = "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	wield_image =  "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	post_effect_color = {a = 60, r = 100, g = 100, b = 100},
	damage_per_second = 1,
	drowning = 1,
	interval = 3,
	weight = -8,
	deathchance = 5,
})

gas_lib.register_gas("gas_lib:steam", {
	description = 'Steam',
	tiles = {{
		name = "steam.png^gui_hb_bg.png",
		--backface_culling=false,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 6,
		},
	}},
	inventory_image = "steam.png^[verticalframe:16:1^gui_hb_bg.png",
	wield_image =  "steam.png^[verticalframe:16:1^gui_hb_bg.png",
	post_effect_color = {a = 60, r = 100, g = 100, b = 100},
	damage_per_second = 3,
	interval = 3,
	weight = -7,
	lifetime = 20,
	liquid = "default:water_source",
	deathchance = 2,
})

minetest.register_abm{
	label="Smoke Gen",
	nodenames= {"group:smokey"},
	neighbors={"air"},
	interval=4,
	chance=1,
	action=function(pos)
		--prefer to spawn smoke above the item
		local newpos = vector.offset(pos, 0, 1, 0)
		--minetest.chat_send_all(minetest.pos_to_string(newpos))
		if minetest.get_node(newpos).name ~= "air" then
			newpos = nil
		end
		if newpos == nil then--prefer behind for things with a facedir
			local node = minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			if def and def.paramtype2 and def.paramtype2 == "facedir" then
				local dir = minetest.facedir_to_dir(node.param2)
				newpos = vector.add(pos, dir)
				if minetest.get_node(newpos).name ~= "air" then
					newpos = nil
				end
			end
		end
		if newpos == nil then--small search
			newpos = minetest.find_node_near(pos, 1, "air")
		end
		if newpos == nil then--larger search
			local newpos = minetest.find_node_near(pos, 4, "air")
		end
		if newpos == nil and math.random(20) == 1 then--chance to start a fire
			local newpos = minetest.find_node_near(pos, 5, "group:flammable")
			if newpos then
				minetest.add_node(newpos, {name = "fire:basic_flame"})
			end
			return
		end
		if newpos and math.random(1, minetest.get_item_group(minetest.get_node(pos).name, "smokey"))==1 then
			minetest.add_node(newpos, {name = "gas_lib:smoke"})
		end
	end
}

local water_def = minetest.registered_nodes["default:water_source"]
water_def.groups.vaporizable = 1
minetest.override_item("default:water_source", { gas="gas_lib:steam", groups = water_def.groups, gas_byproduct = "default:dirt"})

add_group("default:furnace_active", "smokey", 1)
add_group("fire:basic_flame", "smokey", 2)
add_group("default:lava_source", "smokey", 20)
if minetest.get_modpath("technic") then
	add_group("technic:coal_alloy_furnace_active", "smokey", 1)
	add_group("technic:hv_generator_active", "smokey", 1)
	add_group("technic:mv_generator_active", "smokey", 1)
	add_group("technic:lv_generator_active", "smokey", 1)
end