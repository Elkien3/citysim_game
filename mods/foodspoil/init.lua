function cooking_aftercraft(itemstack, old_craft_grid)
	local name = itemstack:get_name()
	--if the output has no expiration, don't do anything.
	local expiredef = minetest.registered_items[name].expiration
	if not expiredef then return itemstack end
	local day_count = minetest.get_day_count()
	local avg = 0
	--if the item is being cooked, dosnt matter how old the items used are
	--local method = minetest.get_craft_recipe(name).method
	--if method ~= "cooking" and method ~= "baking" and method ~= "stovecook" then
		--get the average expiration percentage of each item in recipe
		local expirations = {}
		for index, stack in pairs(old_craft_grid) do
			local meta = stack:get_meta()
			local expire = meta:get_int("ed")
			local usedexpiredef = minetest.registered_items[stack:get_name()].expiration
			if expire ~= 0 and usedexpiredef then
				local expirefactor = (expire - minetest.get_day_count())/usedexpiredef
				if expirefactor < -1 then expirefactor = -1 end
				if expirefactor > 1 then expirefactor = 1 end
				table.insert(expirations, expirefactor)
			end
		end
		for index, val in pairs(expirations) do
			avg = avg + val
		end
		avg = avg/#expirations
	--end

	--make and set new expire time based on average of items used
	local newexpiration = day_count + math.floor(expiredef*avg)
	local meta = itemstack:get_meta()
	meta:set_int("ed", newexpiration)
	meta:set_string("description", minetest.registered_items[name].description.." ed: "..newexpiration)
	return itemstack
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	cooking_aftercraft(itemstack, old_craft_grid)
end)

local old_func = minetest.handle_node_drops
minetest.handle_node_drops = function(pos, drops, digger)
	for index, stack in pairs(drops) do
		local name = stack
		if type(name) == "userdata" then
			name = stack:get_name()
		end
		local def = minetest.registered_items[string.gsub(name," .*", "")]
		if def and def.expiration then
			local nodemeta = minetest.get_meta(pos)
			local expiredef = def.expiration
			local newexpiration
			if nodemeta and nodemeta:get_int("ed") ~= 0 then
				newexpiration = nodemeta:get_int("ed")
			else
				newexpiration = minetest.get_day_count() + expiredef
			end
			drops[index] = ItemStack(stack)
			local meta = drops[index]:get_meta()
			meta:set_int("ed", newexpiration)
			meta:set_string("description", def.description.." ed: "..newexpiration)
		end
	end
	return old_func(pos, drops, digger)
end

local func = minetest.add_item

minetest.add_item = function(pos, item)
	if not item.get_name then
		item = ItemStack(item)
	end
	local name = item:get_name()
	local def = minetest.registered_items[name]
	local meta = item:get_meta()
	if def and def.expiration and meta:get_int("ed") == 0 then
		local expiredef = def.expiration
		local newexpiration = minetest.get_day_count() + expiredef
		meta:set_int("ed", newexpiration)
		meta:set_string("description", minetest.registered_items[name].description.." ed: "..newexpiration)
	end
	return func(pos, item)
end

function foodspoil_register(itemstring, expiration)
	if not itemstring or not expiration then return end
	local nodedef = minetest.registered_nodes[itemstring]
	if nodedef then
		local func = nodedef.after_place_node
		local after_place = function(pos, placer, itemstack, pointed_thing)
			local returnval
			if func then returnval = func(pos, placer, itemstack, pointed_thing) else returnval = false end
			if itemstack:get_meta():get_int("ed") ~= 0 then
				minetest.get_meta(pos):set_int("ed", itemstack:get_meta():get_int("ed"))
			end
			return returnval or false
		end
		minetest.override_item(itemstring, {expiration = expiration, after_place_node = after_place})
	elseif minetest.registered_items[itemstring] then
		minetest.override_item(itemstring, {expiration = expiration})
	end
end

minetest.register_on_mods_loaded(function()
	local org_eat = core.do_item_eat
	core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
		local expire = itemstack:get_meta():get_int("ed")
		if expire ~= 0 then
			local usedexpiredef = minetest.registered_items[itemstack:get_name()].expiration
			local expirefactor = (expire - minetest.get_day_count())/usedexpiredef
			expirefactor = expirefactor + 1
			if expirefactor < -1 then expirefactor = -1 end
			if expirefactor > 1 then expirefactor = 1 end
			hp_change = hp_change*expirefactor
		end
		return org_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	end
	
	if hbhunger then
		local food = hbhunger.food
		hbhunger.eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
			local item = itemstack:get_name()
			local def = food[item]			
			if not def then
				def = {}
				if type(hp_change) ~= "number" then
					hp_change = 1
					core.log("error", "Wrong on_use() definition for item '" .. item .. "'")
				end
				def.saturation = hp_change * 1.3
				def.replace = replace_with_item
			end
			
			local saturation = def.saturation
			local poisen = def.poisen or 0
			local expire = itemstack:get_meta():get_int("ed")
			if expire ~= 0 then
				local usedexpiredef = minetest.registered_items[item].expiration
				local expirefactor = (expire - minetest.get_day_count())/usedexpiredef
				expirefactor = expirefactor + 1
				if expirefactor < -1 then expirefactor = -1 end
				if expirefactor > 1 then expirefactor = 1 end
				if expirefactor > 0 then
					saturation = saturation*expirefactor
				else
					poisen = poisen + saturation*expirefactor*2
					saturation = 0
				end
			end
			if poisen == 0 then poisen = nil end
			local func = hbhunger.item_eat(saturation, def.replace, poisen, def.healing, def.sound)
			return func(itemstack, user, pointed_thing)
		end
	end
end)

local foodtable = {
	["default:apple"] = 24,
	["ethereal:banana"] = 24,
	["ethereal:orange"] = 24,
	["ethereal:strawberry"] = 24,
	["farming:baked_potato"] = false,
	["farming:barley"] = 120,
	["farming:beans"] = false,
	["farming:beetroot"] = false,
	["farming:beetroot_soup"] = 24,
	["farming:blueberries"] = 24,
	["farming:blueberry_pie"] = 24,
	["farming:bread"] = 24,
	["farming:bread_multigrain"] = 30,
	["farming:bread_slice"] = 30,
	["farming:carrot"] = false,
	["farming:carrot_juice"] = false,
	["farming:chili_bowl"] = false,
	["farming:chili_pepper"] = false,
	["farming:chocolate_dark"] = false,
	["farming:cocoa_beans"] = false,
	["farming:coffee_beans"] = false,
	["farming:coffee_cup"] = 3,
	["farming:cookie"] = 24,
	["farming:corn"] = false,
	["farming:corn_cob"] = false,
	["farming:cornstarch"] = 120,
	["farming:cucumber"] = false,
	["farming:donut"] = 24,
	["farming:donut_apple"] = 24,
	["farming:donut_chocolate"] = 24,
	["farming:flour"] = 30,
	["farming:flour_multigrain"] = 30,
	["farming:garlic"] = false,
	["farming:garlic_braid"] = false,
	["farming:garlic_bread"] = 30,
	["farming:garlic_clove"] = false,
	["farming:grapes"] = 24,
	["farming:jaffa_cake"] = 24,
	["farming:melon_slice"] = 24,
	["farming:melon_8"] = false,
	["farming:melon_9"] = false,
	["farming:melon_slice"] = false,
	["farming:muffin_blueberry"] = 24,
	["farming:oat"] = 120,
	["farming:onion"] = false,
	["farming:pea_pod"] = false,
	["farming:pea_soup"] = 24,
	["farming:peas"] = false,
	["farming:pepper"] = false,
	["farming:pineapple"] = 24,
	["farming:pineapple_juice"] = false,
	["farming:pineapple_ring"] = false,
	["farming:porridge"] = 24,
	["farming:potato"] = false,
	["farming:potato_salad"] = 24,
	["farming:pumpkin_8"] = false,
	["farming:pumpkin_9"] = false,
	["farming:pumpkin_bread"] = 24,
	["farming:pumpkin_dough"] = 24,
	["farming:pumpkin_slice"] = 24,
	["farming:raspberries"] = 24,
	["farming:rhubarb"] = 24,
	["farming:rhubarb_pie"] = 24,
	["farming:rice"] = 120,
	["farming:rice_bread"] = false,
	["farming:rice_flour"] = false,
	["farming:rye"] = 120,
	["farming:smoothie_raspberry"] = false,
	["farming:straw" ]= 120,
	["farming:toast"] = 24,
	["farming:toast_sandwich"] = 24,
	["farming:tomato"] = 24,
	["farming:turkish_delight"] = 24,
	["farming:wheat"] = 120,
	["flowers:mushroom_brown"] = false,
	["flowers:mushroom_red"] = false,
	["cake:cake_uncooked"] = 24,
	["cake:cake"] = 24,
	["mobs:meat_raw"] = 24,
	["mobs:meat"] = 24,
	["mobs:chicken_raw"] = 24,
	["mobs:chicken_cooked"] = 24,
	["mobs:butter"] = 24,
	["mobs:bucket_milk"] = 7,
	["mobs:cheese"] = 30,
	["fishing:fish_raw"] = 24,
	["fishing:fish_baked"] = 24,
}

minetest.register_on_mods_loaded(function()
	for name, days in pairs(foodtable) do
		foodspoil_register(name, days or 60)
	end
end)

dofile(minetest.get_modpath("foodspoil").."/icebox.lua")