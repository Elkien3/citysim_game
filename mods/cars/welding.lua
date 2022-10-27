local search_radius = 1

local welder_max_load = 3
local technic_charge_amount = 3000
local cooldowntime = 1
local cooldowns = {}
local welderdef = {
	description = "Welding Torch",
	inventory_image = "weild_torch_inv.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not name then return end
		local inv = minetest.get_inventory({type="player", name=name})
		local meta = itemstack:get_meta()
		if technic then
			local charge = (minetest.deserialize(meta:get_string("")) or {}).charge or 0
			local loaded = meta:get_int("loaded")
			if loaded < 1 then
				if inv:remove_item("main", "default:steel_ingot"):get_count() >= 1 then
					meta:set_int("loaded", welder_max_load)
					loaded = welder_max_load
				else
					return itemstack
				end
			end
			
			if not pointed_thing then return itemstack end
			if pointed_thing.type == "node" then
				local pos = pointed_thing.under
				local node = minetest.get_node(pos)
				local pos1 = vector.subtract(pos, search_radius)
				local pos2 = vector.add(pos, search_radius)
				local nodes = minetest.find_nodes_in_area(pos1, pos2, {"cars:engine"})
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
			elseif pointed_thing.type == "object" then
				local obj = pointed_thing.ref
				if not obj or not obj:get_armor_groups().vehicle then return itemstack end
				if obj:get_hp() >= obj:get_properties().hp_max then return itemstack end--todo add reassembling repair and only allow welding for hp above 50%
				if default.player_attached[name] then return itemstack end
				if cooldowns[name] then return itemstack end
				
				if charge >= technic_charge_amount/welder_max_load and loaded >= 1 then
					charge = charge - technic_charge_amount/welder_max_load
					loaded = loaded - 1
					meta:set_string("", minetest.serialize({["charge"] = charge}))
					meta:set_int("loaded", loaded)
					itemstack = technic.set_RE_wear(itemstack, charge, technic_charge_amount)
					obj:punch(user, nil, {damage_groups={vehicle=-1}})
					cooldowns[name] = true
					minetest.after(cooldowntime, function() cooldowns[name] = nil end)
				end
				return itemstack
			else
				local max_wear = 65534
				local wear = itemstack:get_wear()
				if wear >= max_wear then
					if inv:remove_item("main", "default:steel_ingot"):get_count() >= 1 then
					wear = 1
					itemstack:set_wear(1)
					else
						return itemstack
					end
				end
				
				if not pointed_thing or not pointed_thing.type == "object" then return itemstack end
				local obj = pointed_thing.ref
				if not obj or not obj:get_armor_groups().vehicle then return itemstack end
				if obj:get_hp() >= obj:get_properties().hp_max then return itemstack end
				if default.player_attached[name] then return itemstack end
				if cooldowns[name] then return itemstack end
				
				wear = math.ceil(wear + max_wear/welder_max_load)
				if wear > max_wear then
					wear = max_wear
				end
				itemstack:set_wear(wear)
				obj:punch(user, nil, {damage_groups={vehicle=-1}})
				cooldowns[name] = true
				minetest.after(cooldowntime, function() cooldowns[name] = nil end)
				return itemstack
			end
		end
	end,
}

if technic then
	welderdef.wear_represents = "technic_RE_charge"
	welderdef.on_refill = technic.refill_RE_charge
else
	welderdef.wear_represents = "steel_loaded"
end

minetest.register_tool("cars:welding_torch", welderdef)

if technic then
	technic.register_power_tool("cars:welding_torch", technic_charge_amount)
	minetest.register_craft({
		output = "cars:welding_torch",
		recipe = {
			{"basic_materials:heating_element", "basic_materials:heating_element", "technic:copper_coil"},
			{"", "technic:stainless_steel_ingot", "technic:battery"},
			{"", "technic:stainless_steel_ingot", "technic:battery"},
		}
	})
else
	minetest.register_craft({
		output = "cars:welding_torch",
		recipe = {
			{"default:copper_ingot", "default:copper_ingot", "default:diamond"},
			{"", "default:steel_ingot", "default:mese_crystal"},
			{"", "default:steel_ingot", "default:mese_crystal"},
		}
	})
end