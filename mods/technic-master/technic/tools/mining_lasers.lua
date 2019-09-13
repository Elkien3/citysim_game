local mining_lasers_list = {
--	{<num>, <range of the laser shots>, <max_charge>, <charge_per_shot>},
	{"1", 7, 50000, 1000},
	{"2", 14, 200000, 2000},
	{"3", 21, 650000, 3000},
}
local allow_entire_discharging = true

local S = technic.getter

--[[
minetest.register_craft({
	output = "technic:laser_mk1",
	recipe = {
		{"default:diamond", "technic:brass_ingot",        "default:obsidian_glass"},
		{"",                "technic:brass_ingot",        "technic:red_energy_crystal"},
		{"",                "",                           "default:copper_ingot"},
	}
})
minetest.register_craft({
	output = "technic:laser_mk2",
	recipe = {
		{"default:diamond", "technic:carbon_steel_ingot", "technic:laser_mk1"},
		{"",                "technic:carbon_steel_ingot", "technic:green_energy_crystal"},
		{"",                "",                           "default:copper_ingot"},
	}
})
minetest.register_craft({
	output = "technic:laser_mk3",
	recipe = {
		{"default:diamond", "technic:carbon_steel_ingot", "technic:laser_mk2"},
		{"",                "technic:carbon_steel_ingot", "technic:blue_energy_crystal"},
		{"",                "",                           "default:copper_ingot"},
	}
})
--]]

local function laser_node(pos, node, player)
	local def = minetest.registered_nodes[node.name]
	if def.liquidtype ~= "none" and def.buildable_to then
		minetest.remove_node(pos)
		minetest.add_particle({
			pos = pos,
			velocity = {x = 0, y = 1.5 + math.random(), z = 0},
			acceleration = {x = 0, y = -1, z = 0},
			size = 6 + math.random() * 2,
			texture = "smoke_puff.png^[transform" .. math.random(0, 7),
		})
		return
	end
	minetest.node_dig(pos, node, player)
end

local keep_node = {air = true}
local function can_keep_node(name)
	if keep_node[name] ~= nil then
		return keep_node[name]
	end
	keep_node[name] = minetest.get_item_group(name, "hot") ~= 0
	return keep_node[name]
end

local function laser_shoot(player, range, particle_texture, sound)
	local player_pos = player:getpos()
	local player_name = player:get_player_name()
	local dir = player:get_look_dir()

	local start_pos = vector.new(player_pos)
	-- Adjust to head height
	start_pos.y = start_pos.y + (player:get_properties().eye_height or 1.625)
	minetest.add_particle({
		pos = start_pos,
		velocity = dir,
		acceleration = vector.multiply(dir, 50),
		expirationtime = (math.sqrt(1 + 100 * (range + 0.4)) - 1) / 50,
		size = 1,
		texture = particle_texture .. "^[transform" .. math.random(0, 7),
	})
	minetest.sound_play(sound, {pos = player_pos, max_hear_distance = range})
	for pos in technic.trace_node_ray_fat(start_pos, dir, range) do
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			break
		end
		local node = minetest.get_node(pos)
		if node.name == "ignore"
				or not minetest.registered_nodes[node.name] then
			break
		end
		if not can_keep_node(node.name) then
			laser_node(pos, node, player)
		end
	end
end

for _, m in pairs(mining_lasers_list) do
	--technic.register_power_tool("technic:laser_mk"..m[1], m[3])
	minetest.register_tool("technic:laser_mk"..m[1], {
		description = S("Mining Laser Mk%d REMOVED, USE CRAFT TO HAVE ORES USED RETURNED (BEST TO HAVE SPACE IN YOUR INVENTORY)"):format(m[1]),
		inventory_image = "technic_mining_laser_mk"..m[1]..".png^cross.png",
		wield_image = "technic_mining_laser_mk"..m[1]..".png",
		range = 0,
		stack_max = 1,
		wear_represents = "technic_RE_charge",
		on_refill = technic.refill_RE_charge,
		--[[on_use = function(itemstack, user)
			local meta = minetest.deserialize(itemstack:get_metadata())
			if not meta or not meta.charge or meta.charge == 0 then
				return
			end

			local range = m[2]
			if meta.charge < m[4] then
				if not allow_entire_discharging then
					return
				end
				-- If charge is too low, give the laser a shorter range
				range = range * meta.charge / m[4]
			end
			laser_shoot(user, range, "technic_laser_beam_mk" .. m[1] .. ".png",
				"technic_laser_mk" .. m[1])
			if not technic.creative_mode then
				meta.charge = math.max(meta.charge - m[4], 0)
				technic.set_RE_wear(itemstack, meta.charge, m[3])
				itemstack:set_metadata(minetest.serialize(meta))
			end
			return itemstack
		end,--]]
	})
end

local mk1items = {}
--table.insert(mk1items, "default:diamond 10")
table.insert(mk1items, "default:copper_ingot 9")
table.insert(mk1items, "technic:brass_ingot 2")
table.insert(mk1items, "default:obsidian_glass")
table.insert(mk1items, "dye:red 2")
table.insert(mk1items, "moreores:silver_ingot 2")
table.insert(mk1items, "default:wood 24")
table.insert(mk1items, "default:tin_ingot 4")

local mk2items = {}
table.insert(mk2items, "default:diamond 10")
table.insert(mk2items, "default:copper_ingot 17")
table.insert(mk2items, "dye:red 2")
table.insert(mk2items, "dye:green 2")
table.insert(mk2items, "moreores:silver_ingot 2")
table.insert(mk2items, "technic:carbon_steel_ingot 2")
table.insert(mk2items, "default:wood 48")
table.insert(mk2items, "default:tin_ingot 8")
table.insert(mk2items, "default:gold_ingot 2")

local mk3items = {}
table.insert(mk3items, "default:diamond 10")
table.insert(mk3items, "default:copper_ingot 25")
table.insert(mk3items, "moreores:mithril_ingot 2")
table.insert(mk3items, "dye:red 2")
table.insert(mk3items, "dye:green 2")
table.insert(mk3items, "dye:blue 2")
table.insert(mk3items, "moreores:silver_ingot 2")
table.insert(mk3items, "technic:carbon_steel_ingot 2")
table.insert(mk3items, "default:wood 72")
table.insert(mk3items, "default:tin_ingot 12")
table.insert(mk3items, "default:gold_ingot 2")

minetest.register_craft({
	type = "shapeless",
	output = "technic:laser_mk2",
	recipe = {"technic:laser_mk3"}
})

minetest.register_craft({
	type = "shapeless",
	output = "technic:laser_mk1",
	recipe = {"technic:laser_mk2"}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:diamond 10",
	recipe = {"technic:laser_mk1"}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local item = itemstack:get_name()
	if item == "technic:laser_mk2" then
		local inv = player:get_inventory()
		local pos = player:get_pos()
		for id, name in pairs (mk3items) do
			if inv:room_for_item("craft", name) then
				inv:add_item("craft", name)
			elseif inv:room_for_item("main", name) then
				inv:add_item("main", name)
			else
				minetest.add_item(pos, name)
			end
		end
	elseif item == "technic:laser_mk1" then
		local inv = player:get_inventory()
		local pos = player:get_pos()
		for id, name in pairs (mk2items) do
			if inv:room_for_item("craft", name) then
				inv:add_item("craft", name)
			elseif inv:room_for_item("main", name) then
				inv:add_item("main", name)
			else
				minetest.add_item(pos, name)
			end
		end
	elseif item == "default:diamond" and itemstack:get_count() == 10 then
		local inv = player:get_inventory()
		local pos = player:get_pos()
		for id, name in pairs (mk1items) do
			if inv:room_for_item("craft", name) then
				inv:add_item("craft", name)
			elseif inv:room_for_item("main", name) then
				inv:add_item("main", name)
			else
				minetest.add_item(pos, name)
			end
		end
	end
	return itemstack
end)