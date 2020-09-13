local modpath, S = ...

petz.increase_egg_count = function(self)
	mobkit.remember(self, "eggs_count", self.eggs_count+1)
end

--Lay Egg
petz.lay_egg = function(self)
	if self.eggs_count >= petz.settings.max_laid_eggs then
		return
	end
	if petz.isinliquid(self) then --do not put eggs when in liquid
		return
	end
	local pos = self.object:get_pos()
	if self.type_of_egg == "item" then
		if math.random(1, petz.settings.lay_egg_chance) == 1 then
			minetest.add_item(pos, "petz:"..self.type.."_egg") --chicken/duck/penguin egg!
			petz.increase_egg_count(self)
		end
	end
	if self.lay_eggs_in_nest == true then
		local lay_range = 1
		local nearby_nodes = minetest.find_nodes_in_area(
			{x = pos.x - lay_range, y = pos.y - 1, z = pos.z - lay_range},
			{x = pos.x + lay_range, y = pos.y + 1, z = pos.z + lay_range},
			"petz:ducky_nest")
		if #nearby_nodes > 1 then
			local nest_to_lay = nearby_nodes[math.random(1, #nearby_nodes)]
			minetest.set_node(nest_to_lay, {name= "petz:"..self.type.."_nest_egg"})
			petz.increase_egg_count(self)
		end
	end
end

--Extract Egg from a Nest
petz.extract_egg_from_nest = function(pos, player, egg_type)
	local inv = player:get_inventory()
	if inv:room_for_item("main", egg_type) then
		inv:add_item("main", egg_type) --add the egg to the player's inventory
		minetest.set_node(pos, {name= "petz:ducky_nest"}) --Replace the node to a empty nest
	else
		minetest.chat_send_player(player:get_player_name(), "No room in your inventory for the egg.")
	end
end
