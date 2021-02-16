local TIME_SPEED = minetest.settings:get("time_speed") or 72

function cooking_aftercraft(itemstack, old_craft_grid)
	local name = itemstack:get_name()
	--if the output has no expiration, don't do anything.
	local expiredef = minetest.registered_items[name].expiration
	if not expiredef then return end
	local day_count = minetest.get_day_count()
	local avg = 0
	--if the item is being cooked, dosnt matter how old the items used are
	local method = minetest.get_craft_recipe(name).method
	--if method ~= "cooking" and method ~= "baking" and method ~= "stovecook" then
		--get the average expiration percentage of each item in recipe
		local expirations = {}
		for index, stack in pairs(old_craft_grid) do
			local meta = stack:get_meta()
			local expire = meta:get_int("ed")
			local usedexpiredef = minetest.registered_items[stack:get_name()].expiration
			if expire and usedexpiredef then
				local expirefactor = (expire - day_count - usedexpiredef)/-usedexpiredef
				if expirefactor <= 0 then expirefactor = 0 end
				table.insert(expirations, expirefactor)
			end
		end
		for index, val in pairs(expirations) do
			avg = avg + val
		end
		avg = avg/#expirations
	--end

	--make and set new expire time based on average of items used
	local newexpiration = day_count + expiredef
	local meta = itemstack:get_meta()
	newexpiration = newexpiration - math.floor(expiredef*avg)
	meta:set_int("ed", newexpiration)
	meta:set_string("description", minetest.registered_items[name].description.." ed: "..newexpiration)
	return itemstack
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	cooking_aftercraft(itemstack, old_craft_grid)
end)

local old_func = minetest.handle_node_drops
minetest.handle_node_drops = function(pos, drops, digger)
	for index, name in pairs(drops) do
		local def = minetest.registered_items[string.gsub(name," .*", "")]
		if def and def.expiration then
			local nodemeta = minetest.get_meta(pos)
			local expiredef = def.expiration
			local newexpiration = minetest.get_day_count() + expiredef
			if nodemeta and nodemeta:get_int("ed") ~= 0 then
				newexpiration = nodemeta:get_int("ed")
			end
			minetest.chat_send_all(drops[index]:get_count())
			drops[index] = ItemStack(name)
			local meta = drops[index]:get_meta()
			meta:set_int("ed", newexpiration)
			meta:set_string("description", def.description.." ed: "..newexpiration)
		end
	end
	return old_func(pos, drops, digger)
end

local func = minetest.add_item

minetest.add_item = function(pos, item)
	local name = item:get_name()
	local def = minetest.registered_items[name]
	local meta = item:get_meta()
	if def.expiration and meta:get_int("ed") == 0 then
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

local foodtable = {
--"default:apple",
"ethereal:banana",
"ethereal:orange",
"ethereal:strawberry",
"farming:baked_potato",
"farming:barley",
"farming:beans",
"farming:beetroot",
"farming:beetroot_soup",
"farming:blueberries",
"farming:blueberry_pie",
--"farming:bread",
"farming:bread_multigrain",
"farming:bread_slice",
"farming:carrot",
"farming:carrot_juice",
"farming:chili_bowl",
"farming:chili_pepper",
"farming:chocolate_dark",
"farming:cocoa_beans",
"farming:coffee_beans",
"farming:coffee_cup",
"farming:cookie",
"farming:corn",
"farming:corn_cob",
"farming:cornstarch",
"farming:cucumber",
"farming:donut",
"farming:donut_apple",
"farming:donut_chocolate",
--"farming:flour",
"farming:flour_multigrain",
"farming:garlic",
"farming:garlic_braid",
"farming:garlic_bread",
"farming:garlic_clove",
"farming:grapes",
"farming:jaffa_cake",
"farming:melon_slice",
"farming:melon_8",
"farming:melon_9",
"farming:melon_slice",
"farming:muffin_blueberry",
"farming:oat",
"farming:onion",
"farming:pea_pod",
"farming:pea_soup",
"farming:peas",
"farming:pepper",
"farming:pineapple",
"farming:pineapple_juice",
"farming:pineapple_ring",
"farming:porridge",
"farming:potato",
"farming:potato_salad",
"farming:pumpkin_8",
"farming:pumpkin_9",
"farming:pumpkin_bread",
"farming:pumpkin_dough",
"farming:pumpkin_slice",
"farming:raspberries",
"farming:rhubarb",
"farming:rhubarb_pie",
"farming:rice",
"farming:rice_bread",
"farming:rice_flour",
"farming:rye",
"farming:smoothie_raspberry",
--"farming:straw",
"farming:toast",
"farming:toast_sandwich",
"farming:tomato",
"farming:turkish_delight",
--"farming:wheat",
"flowers:mushroom_brown",
"flowers:mushroom_red",
"cake:cake_uncooked",
"cake:cake"
}

minetest.register_on_mods_loaded(function()
	foodspoil_register("farming:wheat", 60)
	foodspoil_register("farming:straw", 60)
	foodspoil_register("farming:flour", 30)
	foodspoil_register("farming:bread", 6)
	foodspoil_register("default:apple", 6)
	foodspoil_register("mobs:meat_raw", 6)
	foodspoil_register("mobs:meat", 6)
	for i, name in pairs(foodtable) do
		foodspoil_register(name, 6)
	end
end)

local function get_sign(n)
	return n == 0 and 0 or math.abs(n)/n
end

minetest.register_on_mods_loaded(function()
	local org_eat = core.do_item_eat
	core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
		local expire = itemstack:get_meta():get_int("ed")
		if expire ~= 0 then
			local usedexpiredef = minetest.registered_items[itemstack:get_name()].expiration
			local expirefactor = (expire - os.time() - usedexpiredef)/-usedexpiredef
			if expirefactor > 1 then
				expirefactor = expirefactor - 1
				expirefactor = expirefactor/.5
				local sign = get_sign(hp_change)
				hp_change = hp_change - (hp_change*expirefactor)
				if get_sign(hp_change) ~= sign then hp_change = 0 end
			end
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
				expirefactor = (expire - os.time() - usedexpiredef)/-usedexpiredef
				if expirefactor > 1 then
					expirefactor = expirefactor - 1
					expirefactor = expirefactor/.5
					local sign = get_sign(saturation)
					saturation = saturation - (saturation*expirefactor)
					if expirefactor > 1 then expirefactor = 1 end
					poisen = poisen + (def.saturation*expirefactor)
					if get_sign(saturation) ~= sign then saturation = 0 end
				end
			end
			if poisen == 0 then poisen = nil end
			local func = hbhunger.item_eat(saturation, def.replace, poisen, def.healing, def.sound)
			return func(itemstack, user, pointed_thing)
		end
	end
end)