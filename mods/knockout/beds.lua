local original = beds.on_rightclick
beds.on_rightclick = function(pos, player)
	local name = knockout.carrying[player:get_player_name()]
	local newplayer = player
	if name and minetest.get_player_by_name(name) and (knockout.downedplayers and not knockout.downedplayers[name]) then
		newplayer = minetest.get_player_by_name(name)
		knockout.carrier_drop(player:get_player_name())
		knockout.wake_up(name)
	end
	original(pos, newplayer)
end