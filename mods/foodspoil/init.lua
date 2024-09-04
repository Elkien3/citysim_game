foodspoil = {}

foodspoil.fast = 3
foodspoil.medium = 30
foodspoil.slow = 120

local fs_f = foodspoil.fast
local fs_m = foodspoil.medium
local fs_s = foodspoil.slow

local DAY_LENGTH = 86400

local function add_date_zero(str)
	if type(str) ~= "string" then
		str = tostring(str)
	end
	if string.len(str) == 1 or string.len(str) == 7 then
		return "0"..str
	else
		return str
	end
end
foodspoil.add_date_zero = add_date_zero

local function unix_to_dateint(unix)
	local datetbl = os.date("*t", unix)
	local datestring = add_date_zero(datetbl.day)..add_date_zero(datetbl.month)..tostring(datetbl.year)
	return tonumber(datestring)
end
foodspoil.unix_to_dateint = unix_to_dateint

local function dateint_to_unix(dateint)
	local datestring = add_date_zero(dateint)
	if string.len(datestring) ~= 8 then
		return 0
	end
	local day = tonumber(string.sub(datestring, 1, 2))
	local month = tonumber(string.sub(datestring, 3, 4))
	local year = tonumber(string.sub(datestring, 5, 8))
	if day > 31 or day == 0 or month > 12 or month == 0 or year < 24 then return 0 end
	return os.time({year = year, month = month, day = day})
end
foodspoil.dateint_to_unix = dateint_to_unix

local function get_new_expiration(expiredef)
	local datetbl = os.date("*t")
	local todayunix = os.time({year = datetbl.year, month = datetbl.month, day = datetbl.day})
	local expireunix = todayunix + (expiredef*DAY_LENGTH)
	return unix_to_dateint(expireunix)
end
foodspoil.get_new_expiration = get_new_expiration

function cooking_aftercraft(itemstack, old_craft_grid)
	local name = itemstack:get_name()
	--if the output has no expiration, don't do anything.
	local expiredef = minetest.registered_items[name].expiration
	if not expiredef then return itemstack end
	local avg = 1
	--if the item is being cooked, dosnt matter how old the items used are
	--local method = minetest.get_craft_recipe(name).method
	--if method ~= "cooking" and method ~= "baking" and method ~= "stovecook" then
		--get the average expiration percentage of each item in recipe
		local expirations = {}
		for index, stack in pairs(old_craft_grid) do
			local meta = stack:get_meta()
			local expire = meta:get_int("ed")
			expire = dateint_to_unix(expire)/DAY_LENGTH
			local usedexpiredef = minetest.registered_items[stack:get_name()].expiration
			if expire ~= 0 and usedexpiredef then
				local usedexpiredef = minetest.registered_items[itemstack:get_name()].expiration
				local expirefactor = ((expire - math.floor(os.time()/DAY_LENGTH))/usedexpiredef)
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
	local newexpiration = get_new_expiration(math.floor(expiredef*avg))
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
			meta:set_string("description", def.description.." ed: "..foodspoil.add_date_zero(newexpiration))
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
		meta:set_string("description", minetest.registered_items[name].description.." ed: "..foodspoil.add_date_zero(newexpiration))
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
		expire = dateint_to_unix(expire)/DAY_LENGTH
		if expire ~= 0 then
			local usedexpiredef = minetest.registered_items[itemstack:get_name()].expiration
			local expirefactor = ((expire - math.floor(os.time()/DAY_LENGTH))/usedexpiredef)
			--expirefactor = expirefactor + 1
			if expirefactor < -1 then expirefactor = -1 end
			if expirefactor > 1 then expirefactor = 1 end
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