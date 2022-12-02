local storage = minetest.get_mod_storage()
local diet_tbl = minetest.deserialize(storage:get_string("data")) or {}
local orig_func = minetest.do_item_eat
minetest.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	if hp_change > 0 then --only care about food
		local name = user:get_player_name()
		local itemname = itemstack:get_name()
		local playertbl = diet_tbl[name] or {}
		if #playertbl > 10 then
			table.remove(playertbl, 1)
		end
		table.insert(playertbl, itemname)
		local eaten_num = 0
		for i, eaten_name in pairs(playertbl) do
			if eaten_name == itemname then
				eaten_num = eaten_num + 1
			end
		end
		diet_tbl[name] = playertbl
		storage:set_string("data", minetest.serialize(diet_tbl))--todo maybe save less than every single item_eat
		if eaten_num > 8 then--makes you a bit poisoned
			hp_change = -1
			minetest.chat_send_player(name, "Your stomach hates "..itemstack:get_description())
		elseif eaten_num > 3 then
			local multi = eaten_num-3
			multi = 1-(multi/5)
			hp_change = math.ceil(hp_change*multi)
			minetest.chat_send_player(name, "Your stomach could do with a change.")
		end
	end
	return orig_func(hp_change, replace_with_item, itemstack, user, pointed_thing)
end