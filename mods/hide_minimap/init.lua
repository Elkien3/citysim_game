minetest.register_privilege("minimap", {
	description = "Allows players to use the minimap",
	give_to_singleplayer = false,
})

local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time > 20 then
		for _,player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local privs = minetest.get_player_privs(name)
			if not privs.minimap then
				player:hud_set_flags({minimap = false})
			elseif privs.minimap == true then
				player:hud_set_flags({minimap = true})
			end
		end
	end
end)
