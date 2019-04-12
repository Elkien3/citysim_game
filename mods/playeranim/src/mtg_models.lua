local Model = require("model")
local Utils = require("utils")

local math_pi, math_sin, math_cos, math_atan2, math_deg, math_min, math_max, minetest_get_node, minetest_registered_nodes =
		math.pi, math.sin, math.cos, math.atan2, math.deg, math.min, math.max, minetest.get_node, minetest.registered_nodes

local get_animation = Utils.player.get_animation
local is_attached = Utils.player.is_attached
local is_swimming = Utils.player.is_swimming
local get_pitch_deg = Utils.player.get_pitch_deg
local get_movement_speed_xz = Utils.player.get_movement_speed_xz
local _get_control_as_yaw = Utils.player.get_control_as_yaw

local BODY_X_ROTATION_SNEAK = tonumber(minetest.settings:get("playeranim.body_x_rotation_sneak")) or 15.0
local ANIMATION_SPEED = tonumber(minetest.settings:get("playeranim.animation_speed")) or 3.1
local ANIMATION_SPEED_SNEAK = tonumber(minetest.settings:get("playeranim.animation_speed_sneak")) or 0.8
local BODY_ROTATION_DELAY = math.max(math.floor(tonumber(minetest.settings:get("playeranim.body_rotation_delay")) or 5), 1)

local function get_control_as_yaw(player)
	return _get_control_as_yaw(player)
end

local function get_head_x_rotation(player)
	return -get_pitch_deg(player)
end

local function get_body_x_rotation(player)
	return player:get_player_control().sneak and BODY_X_ROTATION_SNEAK
			or 0
end

local function get_animation_speed(player)
	return player:get_player_control().sneak and ANIMATION_SPEED_SNEAK
			or ANIMATION_SPEED
end

local function is_player_in_sky(player)
	local pp = player:get_pos()
	local pp_adjust = { x = pp.x, y = pp.y - 0.1, z = pp.z }

	local nd = minetest_registered_nodes[minetest_get_node(pp_adjust).name]
	return nd and not nd.walkable
end

local mtg_animation_effects = {}

mtg_animation_effects.walk = function(animation_func)
	return function(bones, player, time, delayed_yaw)
		local speed = get_animation_speed(player)
		local shake_sin = math_sin(time * speed * math_pi)

		local shake_range_deg, shake_range_cape_deg = 55, -35
		shake_range_deg = math_min(math_max(get_movement_speed_xz(player) * 14, 20), 65) --TODO
		local shake, shake_cape =
				shake_sin * shake_range_deg,
				(shake_sin + 1) * shake_range_cape_deg

		local body_yaw = 0 --get_control_as_yaw(player)
		local body_y = math_deg(body_yaw)
		return animation_func(bones, player, time, delayed_yaw)
				.Body {x = 0, y = body_y, z = 0}
				.Cape {x = shake_cape, y = 0, z = 0}
				.Arm_Left {x = shake, y = 0, z = 0}
				.Arm_Right {x = -shake, y = 0, z = 0}
				.Leg_Left {x = -shake, y = 0, z = 0}
				.Leg_Right {x = shake, y = 0, z = 0}
	end
end

mtg_animation_effects.mine = function(animation_func)
	return function(bones, player, time, delayed_yaw)
		local speed = get_animation_speed(player)
		local pitch = 90 - get_pitch_deg(player)

		local cape_x_range_deg = -5
		local cape_x = (math_sin(time * speed * math_pi) + 1) * cape_x_range_deg

		local shake_x_range_deg, shake_y_range_deg = 10, 10
		local shake_x, shake_y =
				math_sin(2 * time * speed * math_pi) * shake_x_range_deg + pitch,
				math_cos(2 * time * speed * math_pi) * -1
		
		return animation_func(bones, player, time, delayed_yaw)
				.Cape {x = cape_x, y = 0, z = 0}
				.reset "Arm_Right"
				.Arm_Right {x = shake_x, y = shake_y, z = 0}
	end
end

mtg_animation_effects.sky = function(animation_func)
	return function(bones, player, time, delayed_yaw)
		local velocity_y = player:get_player_velocity().y
		local spread = math_min(-velocity_y * 0.75, 10)
		local stoop = math_min(-velocity_y * 1.5, 90)
		local shake = math_sin(velocity_y * 2) * math_min(-velocity_y * 0.25, 3)

		return animation_func(bones, player, time, delayed_yaw)
				.Body {x = stoop, y = 0, z = 0}
				.Head {x = stoop, y = 0, z = 0}
				.Arm_Left {x = 0, y = 0, z = spread + shake}
				.Arm_Right {x = 0, y = 0, z = -spread - shake}
				.Leg_Left {x = 0, y = 0, z = spread - shake}
				.Leg_Right {x = 0, y = 0, z = -spread + shake}
	end
end

local mtg_animation_preset = {}

mtg_animation_preset.stand = function(bones, player, _, delayed_yaw)
	local body_x = get_body_x_rotation(player)
	local head_x = get_head_x_rotation(player)
	local body_y = is_attached(player) and 0 or math_deg(delayed_yaw)
	return bones
			.Body {x = body_x, y = body_y, z = 0}
			.Head {x = body_x + head_x, y = -body_y, z = 0}
			.Leg_Left {x = body_x, y = 0, z = 0}
			.Leg_Right {x = body_x, y = 0, z = 0}
end

mtg_animation_preset.mine = mtg_animation_effects.mine(mtg_animation_preset.stand)
mtg_animation_preset.walk = mtg_animation_effects.walk(mtg_animation_preset.stand)
mtg_animation_preset.walk_mine = mtg_animation_effects.mine(mtg_animation_preset.walk)
mtg_animation_preset.sky = mtg_animation_effects.sky(mtg_animation_preset.stand)
mtg_animation_preset.sky_mine = mtg_animation_effects.sky(mtg_animation_preset.mine)
mtg_animation_preset.sky_walk = mtg_animation_effects.sky(mtg_animation_preset.walk)
mtg_animation_preset.sky_walk_mine = mtg_animation_effects.sky(mtg_animation_preset.walk_mine)

mtg_animation_preset.swim = function(bones, player, time, delayed_yaw)
	local body_y = math_deg(delayed_yaw)

	local x = get_movement_speed_xz(player)
	local r = math_atan2(x, player:get_player_velocity().y)
	local l = math_deg(r)

	local speed = get_animation_speed(player) * 0.75
	local shake_sin = math_sin(time * speed * math_pi)
	local shake_cos = -math_cos(time * speed * math_pi)
	local shake_range_deg = 60
	local shake_x, shake_z = (shake_sin + 0.5) * shake_range_deg, (shake_cos + 1) * 90 + 10

	return mtg_animation_preset.walk(bones, player, time, delayed_yaw)
			.reset "Arm_Left"
			.reset "Arm_Right"
			.Head {x = l, y = 0, z = -body_y}
			.Body({x = l, y = body_y, z = 0}, {x = 0, y = -2.75, z = 0})
			.Arm_Left {x = shake_x, y = 0, z = shake_z}
			.Arm_Right {x = shake_x, y = 0, z = -shake_z}
end

mtg_animation_preset.swim_walk_mine = function(bones, player, time, delayed_yaw)
	local speed = get_animation_speed(player)
	local rarm_sin = math_sin(2 * time * speed * math_pi)
	local rarm_cos = -math_cos(2 * time * speed * math_pi)
	local pitch = get_pitch_deg(player)

	local speed = get_animation_speed(player)
	local larm_shake_sin = math_sin(time * speed * math_pi)
	local larm_shake_range_deg = 30
	local larm_shake = larm_shake_sin * larm_shake_range_deg

	return mtg_animation_preset.swim(bones, player, time, delayed_yaw)
			.reset "Arm_Right"
			.reset "Arm_Left"
			.Arm_Right {x = 180 + 10 * rarm_sin - pitch, y = 10 * rarm_cos, z = 0}
			.Arm_Left {x = larm_shake, y = 0, z = 0}
end

mtg_animation_preset.get_sit = function(body_rotation, body_position)
	return function(bones, player, time, delayed_yaw)
		return mtg_animation_preset.stand(bones, player, time, delayed_yaw)
				.Body(body_rotation, body_position)
				.Leg_Left {x = 90, y = 0, z = 0}
				.Leg_Right {x = 90, y = 0, z = 0}
	end
end

mtg_animation_preset.get_sit_mine = function(body_rotation, body_position)
	local sit = mtg_animation_preset.get_sit(body_rotation, body_position)
	return mtg_animation_effects.mine(sit)
end

mtg_animation_preset.get_lay = function(body_rotation, body_position)
	return function(bones, player, time, delayed_yaw)
		return bones.Body(body_rotation, body_position)
	end
end



local function get_animation_condition(animation)
	local when_rightclick = { stand = "mine", walk = "walk_mine" }
	return function(player)
		local current_animation = get_animation(player).animation
		if player:get_player_control().RMB then
			current_animation = when_rightclick[current_animation]
		end
		return current_animation == animation
	end
end

local function get_animation_condition_in_water(animation)
	return function(player)
		return is_swimming(player)
				and get_animation_condition(animation)(player) 
	end
end

local function get_animation_condition_falling(animation)
	return function(player)
		return is_player_in_sky(player)
			and (0 > player:get_player_velocity().y)
			and get_animation_condition(animation)(player)
	end
end

local function sit_mine_condition(player)
	local ctrl = player:get_player_control()
	return get_animation_condition("sit")(player)
			and (ctrl.LMB or ctrl.RMB)
end

playeranim.register_model("MTG_4_Nov_2017",
		Model.new("player")
				:set_interpolation(false)
				:set_delayed_yaw_frames(BODY_ROTATION_DELAY)
				-- Bones       bone         rotation               position
				:register_bone("Body",      {x = 0, y = 0, z = 0}, {x = 0, y = 6.25, z = 0})
				:register_bone("Head",      {x = 0, y = 0, z = 0}, {x = 0, y = 6.5, z = 0})
				:register_bone("Cape",      {x = 0, y = 0, z = 0}, {x = 0, y = 6.5, z = 1.2})
				:register_bone("Arm_Left",  {x = 0, y = 0, z = 0}, {x = 3.125, y = 5.25, z = 0})
				:register_bone("Arm_Right", {x = 0, y = 0, z = 0}, {x = -3.125, y = 5.25, z = 0})
				:register_bone("Leg_Left",  {x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0})
				:register_bone("Leg_Right", {x = 0, y = 0, z = 0}, {x = -1, y = 0, z = 0})
				-- Animations in order of priority
				:register_animation(
						get_animation_condition_in_water("walk_mine"),
						mtg_animation_preset.swim_walk_mine,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition_in_water("walk"),
						mtg_animation_preset.swim,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition_falling("walk_mine"),
						mtg_animation_preset.sky_walk_mine,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition_falling("walk"),
						mtg_animation_preset.sky_walk,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition_falling("mine"),
						mtg_animation_preset.sky_mine,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition_falling("stand"),
						mtg_animation_preset.sky,
						{ force_update = true, use_time = true })
				:register_animation(
						sit_mine_condition,
						mtg_animation_preset.get_sit_mine({x = 0, y = 0, z = 0}, {x = 0, y = -5.5, z = 0}),
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition("sit"),
						mtg_animation_preset.get_sit({x = 0, y = 0, z = 0}, {x = 0, y = -5.5, z = 0}),
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition("lay"),
						mtg_animation_preset.get_lay({x = 270, y = 0, z = 0}, {x = 0, y = -5.5, z = 0}))
				:register_animation(
						get_animation_condition("stand"),
						mtg_animation_preset.stand,
						{ force_update = true })
				:register_animation(
						get_animation_condition("walk"),
						mtg_animation_preset.walk,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition("mine"),
						mtg_animation_preset.mine,
						{ force_update = true, use_time = true })
				:register_animation(
						get_animation_condition("walk_mine"),
						mtg_animation_preset.walk_mine,
						{ force_update = true, use_time = true })
				:unwrap()
)
