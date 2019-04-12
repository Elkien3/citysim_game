local Animator = require("animator")
local animator_map = {}

minetest.register_on_joinplayer(function(player)
	animator_map[player] = Animator.new(player, playeranim.get_default_player_model())
end)

minetest.register_on_respawnplayer(function(player)
	local animator = animator_map[player]
	if animator then
		animator:yaw_history_clear(player)
	end
end)

do
	-- Avoiding global for performance
	local pairs, minetest_get_connected_players =
			pairs, minetest.get_connected_players

	local function globalstep(dtime)
		for _, player in pairs(minetest_get_connected_players()) do
			local animator = animator_map[player]
			if animator then
				animator:animate(player:get_look_horizontal(), dtime)
			end
		end
	end

	minetest.register_globalstep(globalstep)
end
