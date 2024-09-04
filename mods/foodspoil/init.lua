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
	for index, stack_raw in pairs(drops) do
		local stack = ItemStack(stack_raw)
		local name = stack:get_name()
		local stack_meta = stack:get_meta()
		local def = minetest.registered_items[name]
		if def and def.expiration and stack_meta:get_int("ed") == 0 then
			local node = minetest.get_node(pos)
			local newexpiration = minetest.get_day_count() + def.expiration
			if index == 1 and node.name == name then
				-- Drop is from the node itself dropping; try copying node's ed
				local node_exp = minetest.get_meta(pos):get_int("ed")
				if node_exp > 0 then
					newexpiration = node_exp
				end
			end
			drops[index] = stack
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
end)

local foodtable = {
	["default:apple"] = 32,
	["default:blueberries"] = 24,
	["ethereal:banana"] = 32,
	["ethereal:orange"] = 32,
	["ethereal:strawberry"] = 32,
	["farming:baked_potato"] = false,
	["farming:barley"] = 120,
	["farming:beans"] = false,
	["farming:beetroot"] = false,
	["farming:beetroot_soup"] = 32,
	["farming:blueberries"] = 32,
	["farming:blueberry_pie"] = 32,
	["farming:bread"] = 32,
	["farming:bread_multigrain"] = 36,
	["farming:bread_slice"] = 36,
	["farming:carrot"] = false,
	["farming:carrot_juice"] = false,
	["farming:chili_bowl"] = false,
	["farming:chili_pepper"] = false,
	["farming:chocolate_dark"] = false,
	["farming:cocoa_beans"] = false,
	["farming:coffee_beans"] = false,
	["farming:coffee_cup"] = 3,
	["farming:cookie"] = 32,
	["farming:corn"] = false,
	["farming:corn_cob"] = false,
	["farming:cornstarch"] = 120,
	["farming:cucumber"] = false,
	["farming:donut"] = 32,
	["farming:donut_apple"] = 32,
	["farming:donut_chocolate"] = 32,
	["farming:flour"] = 36,
	["farming:flour_multigrain"] = 36,
	["farming:garlic"] = false,
	["farming:garlic_braid"] = false,
	["farming:garlic_bread"] = 36,
	["farming:garlic_clove"] = false,
	["farming:grapes"] = 32,
	["farming:jaffa_cake"] = 32,
	["farming:melon_slice"] = 32,
	["farming:melon_8"] = false,
	["farming:melon_9"] = false,
	["farming:melon_slice"] = false,
	["farming:muffin_blueberry"] = 32,
	["farming:oat"] = 120,
	["farming:onion"] = false,
	["farming:pea_pod"] = false,
	["farming:pea_soup"] = 32,
	["farming:peas"] = false,
	["farming:pepper"] = false,
	["farming:pineapple"] = 32,
	["farming:pineapple_juice"] = false,
	["farming:pineapple_ring"] = false,
	["farming:porridge"] = 32,
	["farming:potato"] = false,
	["farming:potato_salad"] = 32,
	["farming:pumpkin_8"] = false,
	["farming:pumpkin_9"] = false,
	["farming:pumpkin_bread"] = 32,
	["farming:pumpkin_dough"] = 32,
	["farming:pumpkin_slice"] = 32,
	["farming:raspberries"] = 32,
	["farming:rhubarb"] = 32,
	["farming:rhubarb_pie"] = 32,
	["farming:rice"] = 120,
	["farming:rice_bread"] = false,
	["farming:rice_flour"] = false,
	["farming:rye"] = 120,
	["farming:smoothie_raspberry"] = false,
	["farming:straw" ]= 120,
	["farming:toast"] = 32,
	["farming:toast_sandwich"] = 32,
	["farming:tomato"] = 32,
	["farming:turkish_delight"] = 32,
	["farming:wheat"] = 120,
	["flowers:mushroom_brown"] = false,
	["flowers:mushroom_red"] = false,
	["cake:cake_uncooked"] = 32,
	["cake:cake"] = 32,
	["mobs:meat_raw"] = 32,
	["mobs:meat"] = 32,
	["mobs:chicken_raw"] = 32,
	["mobs:chicken_cooked"] = 32,
	["mobs:butter"] = 32,
	["mobs:bucket_milk"] = 7,
	["mobs:cheese"] = 36,
	["mobs:egg"] = 32,
	["fishing:fish_raw"] = 32,
	["fishing:fish_baked"] = 32,
}

for i, stairtype in pairs({"slab", "stair_inner", "stair_outer", "stair"}) do
	foodtable["stairs:"..stairtype.."_straw"] = 120
end

minetest.register_on_mods_loaded(function()
	for name, days in pairs(foodtable) do
		foodspoil_register(name, days or 60)
	end
end)

dofile(minetest.get_modpath("foodspoil").."/icebox.lua")
