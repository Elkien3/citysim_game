minetest.register_privilege("minimap", {
	description = "Allows players to use the minimap",
	give_to_singleplayer = false,
})

minetest.register_on_joinplayer(function(player, last_login)
	if minetest.check_player_privs(player, {minimap = true}) then
		player:hud_set_flags({minimap = true})
	else
		player:hud_set_flags({minimap = false})
	end
end)

minetest.register_on_priv_grant(function(name, granter, priv)
	if priv == "minimap" then
		local player = minetest.get_player_by_name(name)
		if player then
			player:hud_set_flags({minimap = true})
		end
	end
end)

minetest.register_on_priv_revoke(function(name, revoker, priv)
	if priv == "minimap" then
		local player = minetest.get_player_by_name(name)
		if player then
			player:hud_set_flags({minimap = false})
		end
	end
end)