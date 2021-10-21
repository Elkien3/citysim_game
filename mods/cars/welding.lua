local welder_max_load = 3
local technic_charge_amount = 3000
local cooldowntime = 1
local cooldowns = {}
local welderdef = {
	description = "Welding Torch",
	inventory_image = "welding_torch.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not name then return end
		local inv = minetest.get_inventory({type="player", name=name})
		local meta = itemstack:get_meta()
		if technic then
			local charge = minetest.deserialize(meta:get_string("")).charge
			local loaded = meta:get_int("loaded")
			if loaded < 1 then
				if inv:remove_item("main", "default:steel_ingot"):get_count() >= 1 then
					meta:set_int("loaded", welder_max_load)
					loaded = welder_max_load
				else
					return itemstack
				end
			end
			
			if not pointed_thing or not pointed_thing.type == "object" then return itemstack end
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
end