local flashlight_max_charge = 30000
local flashlight_charge_per_second = 16

local function check_for_flashlight(player)
	if player == nil then
		return false
	end
	local inv = player:get_inventory()
	local hotbar = inv:get_list("main")
	for i = 1, 8 do
		if hotbar[i] and hotbar[i]:get_name() == "technic:flashlight" then
			local meta = minetest.deserialize(hotbar[i]:get_metadata())
			if meta and meta.charge and meta.charge >= flashlight_charge_per_second then
				if not technic.creative_mode then
					meta.charge = meta.charge - flashlight_charge_per_second;
					technic.set_RE_wear(hotbar[i], meta.charge, flashlight_max_charge)
					hotbar[i]:set_metadata(minetest.serialize(meta))
					inv:set_stack("main", i, hotbar[i])
				end
				return true
			end
		end
	end
	return false
end

local wieldtimer = 0
minetest.register_globalstep(function(dtime)
	wieldtimer = wieldtimer + dtime
	if wieldtimer > 1 then
		wieldtimer = 0
		for i,player in ipairs(minetest.get_connected_players()) do
			local wielded_item = player:get_wielded_item()
			if check_for_flashlight(player) then
				beamlight.beams[player:get_player_name()] = {player = player, length = 3}
			elseif wielded_item:get_name() == "nolight:lantern_active" then
				beamlight.beams[player:get_player_name()] = {player = player}
				local meta = wielded_item:get_meta()
				local fuel_time = meta:get_float("fuel_time")
				local fuel_totaltime = meta:get_float("fuel_totaltime")
				if fuel_totaltime ~= 0 then
					fuel_time = fuel_time + 1
					--minetest.chat_send_all(fuel_time)
					if fuel_time > fuel_totaltime then
						local nofuel = true
						if meta:get_string("stack") ~= "" then
							local fuelitem = ItemStack(meta:get_string("stack"))
							local afterfuel
							fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = {fuelitem}})
							fuel.time = fuel.time*10
							if fuel.time == 0 then
								-- No valid fuel in fuel list
								fuel_totaltime = 0
								fuel_time = 0
							else
								-- Take fuel from fuel list
								fuelitem:take_item(1)
								-- Put replacements in dst list or drop them on the furnace.
								local replacements = fuel.replacements
								if replacements[1] then
									local pos = player:get_pos()
									local above = vector.new(pos.x, pos.y + 1, pos.z)
									local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
									minetest.item_drop(replacements[1], nil, drop_pos)
								end
								nofuel = false
								meta:set_string("stack", fuelitem:to_string())
								meta:set_float("fuel_time", 0)
								meta:set_float("fuel_totaltime", fuel.time)
							end
						end
						if nofuel then
							meta:set_float("fuel_time", 0)
							meta:set_float("fuel_totaltime", 0)
							local newstack = ItemStack("nolight:lantern")
							--newstack:get_meta():set_string("stack", meta:get_string("stack"))
							wielded_item:replace(newstack)
						end
					else
						meta:set_float("fuel_time", fuel_time)
					end
					player:set_wielded_item(wielded_item)
				end
			else
				beamlight.beams[player:get_player_name()] = nil
			end
		end
	end
end)