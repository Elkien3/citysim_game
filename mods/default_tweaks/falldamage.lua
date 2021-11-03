minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type == "fall" then
		hp_change = hp_change*2
	end
	return hp_change
end, true)