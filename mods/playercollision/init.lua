local timer = 0
minetest.register_globalstep(function(dtime)
timer = timer + dtime
if timer < .05 then return end
timer = 0
local playerlist = minetest.get_connected_players()
for index, player in pairs (playerlist) do
	local pos1 = player:get_pos()
	for index, player2 in pairs (playerlist) do
		if player:get_player_name() == player2:get_player_name() then goto skip end
		local pos2 = player2:get_pos()
		local dist = vector.distance(pos1, pos2)
		if dist < .6 then
			player:add_player_velocity(vector.multiply(vector.direction(pos2, pos1), 1))
		end
		::skip::
	end
end

end)
minetest.register_on_joinplayer(function(player)
	minetest.after(0, function() 
		local props = player:get_properties()
		props.physical = true
		props.collisionbox = {-.25, 0, -.25, 0.25, 1.7, .25}--{-.3, 0, -.3, 0.3, 1.7, .3}
		player:set_properties(props)
	end)
end)