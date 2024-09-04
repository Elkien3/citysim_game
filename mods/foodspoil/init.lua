foodspoil = {}

foodspoil.fast = 2
foodspoil.medium = 15
foodspoil.slow = 60

local fs_f = foodspoil.fast
local fs_m = foodspoil.medium
local fs_s = foodspoil.slow

local DAY_LENGTH = 86400

local function get_unixday(unix)
	return math.floor(os.time(unix)/DAY_LENGTH)
end
foodspoil.get_unixday = get_unixday

local function format_unixday(unixday)
	local datetbl = os.date("*t", unixday*DAY_LENGTH)
	local datestring = add_date_zero(datetbl.day)..add_date_zero(datetbl.month)..tostring(datetbl.year)
	return datestring
end
foodspoil.format_unixday = format_unixday

local function get_new_expiration(expiredef)
	local todayunixday = get_unixday()
	local expireunixday = todayunixday + expiredef
	return unix_to_dateint(expireunixday)
end
foodspoil.get_new_expiration = get_new_expiration

local function get_expire_factor(expire, expiredef, foreating)
	local expirefactor = ((expire - get_unixday())/expiredef)
	if foreating then--if we are eating the item, we want the factor to stay at 1 until it passes the expiration
		expirefactor = expirefactor + 1
	end
	if expirefactor < -1 then expirefactor = -1 end
	if expirefactor > 1 then expirefactor = 1 end
	return expirefactor
end

function cooking_aftercraft(itemstack, old_craft_grid)
	local name = itemstack:get_name()
	--if the output has no expiration, don't do anything.
	local expiredef = minetest.registered_items[name].expiration
	if not expiredef then return itemstack end
	local avg = 0
	local expirations = {}
	for index, stack in pairs(old_craft_grid) do--get the average expiration percentage of each item in recipe
		local meta = stack:get_meta()
		local expire = meta:get_int("ed")
		local usedexpiredef = minetest.registered_items[stack:get_name()].expiration
		if expire ~= 0 and usedexpiredef then
			local expirefactor = get_expire_factor(expire, usedexpiredef)
			table.insert(expirations, expirefactor)
		end
	end
	for index, val in pairs(expirations) do
		avg = avg + val
	end
	if #expirations > 0 then
		avg = avg/#expirations
	else
		avg = 1
	end

	--make and set new expire time based on average of items used
	local newexpiration = get_new_expiration(expiredef*avg)
	local meta = itemstack:get_meta()
	meta:set_int("ed", newexpiration)
	meta:set_string("description", minetest.registered_items[name].description.." ed: "..add_date_zero(newexpiration))
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
			local newexpiration = get_new_expiration(def.expiration)
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
			meta:set_string("description", def.description.." ed: "..format_unixday(newexpiration))
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
		local newexpiration = get_new_expiration(expiredef)
		meta:set_int("ed", newexpiration)
		meta:set_string("description", minetest.registered_items[name].description.." ed: "..foodspoil.format_unixday(newexpiration))
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
			local expirefactor = get_expire_factor(expire, usedexpiredef, true)
			hp_change = hp_change*expirefactor
		end
		return org_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	end
end)

local foodtable = {
	["default:apple"] = fs_m,
	["default:blueberries"] = fs_m,
	["ethereal:banana"] = fs_m,
	["ethereal:orange"] = fs_m,
	["ethereal:strawberry"] = fs_m,
	["farming:baked_potato"] = fs_m,
	["farming:barley"] = fs_s,
	["farming:beans"] = fs_m,
	["farming:beetroot"] = fs_m,
	["farming:beetroot_soup"] = fs_f,
	["farming:blueberries"] = fs_m,
	["farming:blueberry_pie"] = fs_f,
	["farming:bread"] = fs_m,
	["farming:bread_multigrain"] = fs_m,
	["farming:bread_slice"] = fs_m,
	["farming:carrot"] = fs_m,
	["farming:carrot_juice"] = fs_m,
	["farming:chili_bowl"] = fs_m,
	["farming:chili_pepper"] = fs_m,
	["farming:chocolate_dark"] = fs_m,
	["farming:cocoa_beans"] = fs_m,
	["farming:coffee_beans"] = fs_m,
	["farming:coffee_cup"] = fs_f,
	["farming:cookie"] = fs_m,
	["farming:corn"] = fs_s,
	["farming:corn_cob"] = fs_m,
	["farming:cornstarch"] = fs_s,
	["farming:cucumber"] = fs_m,
	["farming:donut"] = fs_m,
	["farming:donut_apple"] = fs_m,
	["farming:donut_chocolate"] = fs_m,
	["farming:flour"] = fs_s,
	["farming:flour_multigrain"] = fs_s,
	["farming:garlic"] = fs_s,
	["farming:garlic_braid"] = fs_s,
	["farming:garlic_bread"] = fs_m,
	["farming:garlic_clove"] = fs_s,
	["farming:grapes"] = fs_m,
	["farming:jaffa_cake"] = fs_m,
	["farming:melon_slice"] = fs_m,
	["farming:melon_8"] = fs_m,
	["farming:melon_9"] = fs_m,
	["farming:melon_slice"] = fs_m,
	["farming:muffin_blueberry"] = fs_m,
	["farming:oat"] = fs_s,
	["farming:onion"] = fs_s,
	["farming:pea_pod"] = fs_s,
	["farming:pea_soup"] = fs_m,
	["farming:peas"] = fs_s,
	["farming:pepper"] = fs_s,
	["farming:pineapple"] = fs_m,
	["farming:pineapple_juice"] = fs_m,
	["farming:pineapple_ring"] = fs_m,
	["farming:porridge"] = fs_m,
	["farming:potato"] = fs_s,
	["farming:potato_salad"] = fs_m,
	["farming:pumpkin_8"] = fs_m,
	["farming:pumpkin_9"] = fs_m,
	["farming:pumpkin_bread"] = fs_m,
	["farming:pumpkin_dough"] = fs_m,
	["farming:pumpkin_slice"] = fs_m,
	["farming:raspberries"] = fs_m,
	["farming:rhubarb"] = fs_m,
	["farming:rhubarb_pie"] = fs_m,
	["farming:rice"] = fs_s,
	["farming:rice_bread"] = fs_m,
	["farming:rice_flour"] = fs_m,
	["farming:rye"] = fs_s,
	["farming:smoothie_raspberry"] = fs_m,
	["farming:straw" ]= fs_s,
	["farming:toast"] = fs_m,
	["farming:toast_sandwich"] = fs_m,
	["farming:tomato"] = fs_m,
	["farming:turkish_delight"] = fs_m,
	["farming:wheat"] = fs_s,
	["flowers:mushroom_brown"] = fs_m,
	["flowers:mushroom_red"] = fs_m,
	["cake:cake_uncooked"] = fs_m,
	["cake:cake"] = fs_m,
	["mobs:meat_raw"] = fs_m,
	["mobs:meat"] = fs_m,
	["mobs:chicken_raw"] = fs_m,
	["mobs:chicken_cooked"] = fs_m,
	["mobs:butter"] = fs_m,
	["mobs:bucket_milk"] = fs_f,
	["mobs:cheese"] = fs_m,
	["mobs:egg"] = fs_m,
	["fishing:fish_raw"] = fs_m,
	["fishing:fish_baked"] = fs_m,
}

for i, stairtype in pairs({"slab", "stair_inner", "stair_outer", "stair"}) do
	foodtable["stairs:"..stairtype.."_straw"] = fs_s
end

minetest.register_on_mods_loaded(function()
	for name, days in pairs(foodtable) do
		foodspoil_register(name, days or fs_m)
	end
end)

dofile(minetest.get_modpath("foodspoil").."/icebox.lua")