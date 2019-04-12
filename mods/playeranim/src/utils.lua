local math_deg, math_hypot, minetest_get_node, minetest_registered_nodes, RAD45 =
		math.deg, math.hypot, minetest.get_node, minetest.registered_nodes, math.pi / 4

local Utils = {}

Utils.player = {
	is_attached = function(player)
		return player:get_attach() ~= nil
	end,

	is_swimming = function(player)
		local pp = player:get_pos()
		local pp_player = { x = pp.x, y = pp.y + 0.6, z = pp.z }
		local pp_ground = { x = pp.x, y = pp.y - 0.1, z = pp.z }

		local nd_player = minetest_registered_nodes[minetest_get_node(pp_player).name]
		local nd_ground = minetest_registered_nodes[minetest_get_node(pp_ground).name]
		return nd_player and nd_ground and nd_player.groups.water and not nd_ground.walkable
	end,

	get_pitch_deg = function(player)
		return math_deg(player:get_look_vertical())
	end,

	get_movement_speed_xz = function(player)
		local v = player:get_player_velocity()
		return math_hypot(v.x, v.z)
	end,

	get_control_as_yaw = function(player)
		local ctrl = player:get_player_control()

		local up = ctrl.up ~= ctrl.down and ctrl.up
		local down = not up and ctrl.down
		local right = ctrl.right ~= ctrl.left and ctrl.right
		local left = not right and ctrl.left

		if up and right then
			return RAD45
		elseif up and left then
			return RAD45 * -1
		elseif down and right then
			return RAD45 * 3
		elseif down and left then
			return RAD45 * -3
		elseif right and not left then
			return RAD45 * 2
		elseif left and not right then
			return RAD45 * -2
		elseif down and not up then
			return RAD45 * 4
		end
		return 0
	end,

	get_animation = (function()
		local get_animation =
				minetest.global_exists("mcl_player") and mcl_player.player_get_animation
				or minetest.global_exists("player_api") and player_api.get_animation
				or minetest.global_exists("default") and default.player_get_animation

		if not get_animation then
			error("player_api.get_animation or default.player_get_animation is not found")
		end

		if minetest.global_exists("emote") then
			local emote_state = {}
			local emote_start, emote_stop = emote.start, emote.stop

			emote.start = function(player, emotestring)
				local result = emote_start(player, emotestring)
				if result then
					local current_animation = get_animation(player).animation
					emote_state[player] = { emotestring, current_animation }
				end
				return result
			end

			emote.stop = function(player)
				emote_state[player] = nil
				return emote_stop(player)
			end

			local pairs, minetest_get_connected_players = pairs, minetest.get_connected_players
			minetest.register_globalstep(function()
				for _, player in pairs(minetest_get_connected_players()) do
					local state = emote_state[player]
					local animation = get_animation(player).animation
					if state and state[2] ~= animation then
						emote_state[player] = nil
					end
				end
			end)

			return function(player)
				local state = emote_state[player]
				return state and { animation = state[1] } or get_animation(player)
			end
		else
			return get_animation
		end
	end)(),
}

return Utils
