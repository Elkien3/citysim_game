local timer = 0
minetest.register_globalstep(function(dtime)
timer = timer + dtime
if timer < .05 then return end
timer = 0
local playerlist = minetest.get_connected_players()
for index, player in pairs (playerlist) do
	local pos1 = player:get_pos()
	local name1 = player:get_player_name()
	if not default.player_attached[name1] then
		for index, player2 in pairs (playerlist) do
			local name2	= player2:get_player_name()
			if name1 == name2 or default.player_attached[name2] then goto skip end
			local pos2 = player2:get_pos()
			local dist = vector.distance(pos1, pos2)
			if dist < .6 then
				player:add_player_velocity(vector.multiply(vector.direction(pos2, pos1), 1))
			end
			::skip::
		end
	end
end

end)
minetest.register_on_joinplayer(function(player)
	minetest.after(0, function() 
		local props = player:get_properties()
		props.physical = true
		props.collisionbox = {-.26, 0, -.26, 0.26, 1.7, .26}--{-.3, 0, -.3, 0.3, 1.7, .3}
		player:set_properties(props)
	end)
end)