local modpath, S = ...

petz.set_infotext_behive = function(meta, honey_count, bee_count)
	local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_behive
	meta:set_string("infotext", S("Honey")..": "..tostring(honey_count) .." | "..S("Bees Inside")..": "..tostring(bee_count).." | "..S("Total Bees")..": "..tostring(total_bees))
end

petz.decrease_total_bee_count = function(pos)
	local meta = minetest.get_meta(pos)
	local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_behive
	total_bees = total_bees - 1
	meta:set_int("total_bees", total_bees)
end

petz.behive_exists = function(self)
	local behive_exists
	if self.behive then
		local node = minetest.get_node_or_nil(self.behive)
		if node and node.name == "petz:beehive" then
			behive_exists = true
		else
			behive_exists = false
		end
	else
		behive_exists = false
	end
	if behive_exists == true then
		return true
	else
		self.behive = nil
		return false
	end
end

petz.get_behive_stats = function(pos)
	if not(pos) then
		return
	end
	local meta = minetest.get_meta(pos)
	local honey_count = meta:get_int("honey_count") or 0
	local bee_count = meta:get_int("bee_count") or 0
	return meta, honey_count, bee_count
end

petz.spawn_bee_pos = function(pos)	--Check a pos close to a behive to spawn a bee
	local pos_1 = {
		x = pos.x - 1,
		y = pos.y - 1,
		z = pos.z - 1,
	}
	local pos_2 = {
		x = pos.x + 1,
		y = pos.y + 1,
		z = pos.z + 1,
	}
	local spawn_pos_list = minetest.find_nodes_in_area(pos_1, pos_2, {"air"})
	if #spawn_pos_list > 0 then
		return spawn_pos_list[math.random(1, #spawn_pos_list)]
	else
		return nil
	end
end
