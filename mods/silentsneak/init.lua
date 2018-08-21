sneak = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	sneak[name] = false
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	sneak[name] = nil
end)

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local control = player:get_player_control()
		local name = player:get_player_name()
		if control.sneak ~= sneak[name] then
			local c = control.sneak
			if c then
				player:set_properties{makes_footstep_sound = false}
			else
				player:set_properties{makes_footstep_sound = true}
			end
			sneak[name] = c
		end
	end
end)
