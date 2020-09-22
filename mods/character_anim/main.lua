local modeldata_path = modlib.mod.get_resource"modeldata.lua"
if not modlib.file.exists(modeldata_path) then
	modeldata = {}
	assert(import_model("character.b3d"))
else
	modeldata = minetest.deserialize(modlib.file.read(modeldata_path))
end

function linear_interpolation(vector, other_vector, ratio)
	return modlib.vector.add(modlib.vector.multiply_scalar(vector, ratio), modlib.vector.multiply_scalar(other_vector, 1 - ratio))
end

function get_animation_value(animation, keyframe_index, is_rotation)
	local values = animation.values
	assert(keyframe_index >= 1 and keyframe_index <= #values, keyframe_index)
	local ratio = keyframe_index % 1
	if ratio == 0 then
		return values[keyframe_index]
	end
	assert(ratio > 0 and ratio < 1)
	local prev_value, next_value = values[math.floor(keyframe_index)], values[math.ceil(keyframe_index)]
	assert(next_value)
	if is_rotation then
		return quaternion.slerp(prev_value, next_value, ratio)
	end
	return modlib.vector.add(modlib.vector.multiply_scalar(prev_value, ratio), modlib.vector.multiply_scalar(next_value, 1 - ratio))
end

function is_interacting(player)
	local control = player:get_player_control()
	return minetest.check_player_privs(player, "interact") and (control.RMB or control.LMB)
end

local function disable_local_animation(player)
	return player:set_local_animation(nil, nil, nil, nil, 0)
end

local function get_look_horizontal(player)
	return 180-math.deg(player:get_look_horizontal())
end

players = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	disable_local_animation(player)
	players[name] = {
		interaction_time = 0,
		animation_time = 0,
		animation = {},
		look_horizontal = get_look_horizontal(player),
		bone_positions = {}
	}
end)

minetest.register_on_leaveplayer(function(player) players[player:get_player_name()] = nil end)

local function disable_animation(player)
	return player:set_animation({x = 0, y = 0}, 0, 0, false)
end

if player_api then
	-- HACK eventually, player_api should be reimplemented
	local set_animation = player_api.set_animation
	player_api.set_animation = function(player, ...)
		local player_animation = players[player:get_player_name()]
		if not player_animation then
			return
		end
		local ret = {set_animation(player, ...)}
		local range, frame_speed, frame_blend, frame_loop = player:get_animation()
		player_animation.animation = {range, frame_speed, frame_blend, frame_loop}
		disable_animation(player)
		return unpack(ret)
	end
end

local function clamp(value, min, max)
	if value > max then
		return max
	end
	if value < min then
		return min
	end
	return value
end

local function normalize_rotation(euler_rotation)
	return vector.apply(euler_rotation, function(x) return (x % 360) - 180 end)
end

--[[local conf = {
	body = {
		turn_speed = 1/5
	},
	head = {
		pitch = {-60, 80},
		yaw = {-90, 90},
		yaw_restricted = {0, 45},
		yaw_restriction = 60
	},
	arm_right = {
		radius = 10,
		speed = 1000,
		yaw = {-30, 160}
	}
}]]
local function handle_player_animations(dtime, player)
	local mesh = player:get_properties().mesh
	local modeldata = modeldata[mesh]
	if not modeldata then
		return
	end
	local conf = conf.models[mesh] or conf.default
	local name = player:get_player_name()
	local range, frame_speed, frame_blend, frame_loop = player:get_animation()
	disable_animation(player)
	local player_animation = players[name]
	local anim = {range, frame_speed, frame_blend, frame_loop}
	local animation_time = player_animation.animation_time
	if (range.x == 0 and range.y == 0 and frame_speed == 0 and frame_blend == 0 and frame_loop == false) or modlib.table.equals_noncircular(anim, player_animation.animation) then
		range, frame_speed, frame_blend, frame_loop = unpack(player_animation.animation)
		animation_time = animation_time + dtime
	else
		player_animation.animation = anim
		animation_time = 0
	end
	player_animation.animation_time = animation_time
	local range_min, range_max = range.x + 1, range.y + 1
	local keyframe
	if frame_loop then
		keyframe = range_min + ((animation_time * frame_speed) % (range_max - range_min))
	else
		keyframe = math.min(range_max, range_min + animation_time * frame_speed)
	end
	local bone_positions = {}
	for _, bone in ipairs(modeldata.order) do
		local animation = modeldata.animations_by_nodename[bone]
		local position, rotation = animation.default_translation, animation.default_rotation
		if animation.translation then
			position = get_animation_value(animation.translation, keyframe)
		end
		position = {x = -position.x, y = position.y, z = -position.z}
		if animation.rotation then
			-- rotation override instead of additional rotation (quaternion.multiply(animated_rotation, rotation))
			rotation = get_animation_value(animation.rotation, keyframe, true)
		end
		rotation = {unpack(rotation)}
		rotation[1] = -rotation[1]
		local euler_rotation
		local parent = animation.parent
		if parent then
			rotation[4] = -rotation[4]
			local values = bone_positions[parent]
			local absolute_rotation = quaternion.multiply(values.rotation, rotation)
			euler_rotation = vector.subtract(quaternion.to_rotation(absolute_rotation), values.euler_rotation)
		else
			euler_rotation = quaternion.to_rotation(rotation)
		end
		bone_positions[bone] = {position = position, rotation = rotation, euler_rotation = euler_rotation}
	end
	local Body, Head, Arm_Right = bone_positions.Body.euler_rotation, bone_positions.Head.euler_rotation, bone_positions.Arm_Right.euler_rotation
	local look_vertical = -math.deg(player:get_look_vertical())
	Head.x = look_vertical
	-- TODO sneak controlled animation speed (body turn, digging)
	local interacting = is_interacting(player)
	if interacting then
		local interaction_time = player_animation.interaction_time
		-- note: +90 instead +Arm_Right.x because it looks better
		Arm_Right.x = 90 + look_vertical - math.sin(-interaction_time) * conf.arm_right.radius
		Arm_Right.y = Arm_Right.y + math.cos(-interaction_time) * conf.arm_right.radius
		player_animation.interaction_time = interaction_time + dtime * math.rad(conf.arm_right.speed)
	else
		player_animation.interaction_time = 0
	end
	local look_horizontal = get_look_horizontal(player)
	local diff = look_horizontal - player_animation.look_horizontal
	if math.abs(diff) > 180 then
		diff = math.sign(-diff) * 360 + diff
	end
	local moving_diff = math.sign(diff) * math.abs(diff) * math.min(1, dtime / conf.body.turn_speed)
	player_animation.look_horizontal = player_animation.look_horizontal + moving_diff
	if math.abs(moving_diff) < 1e-6 then
		player_animation.look_horizontal = look_horizontal
	end
	local lag_behind = diff - moving_diff
	local attach_parent, _, _, attach_rotation = player:get_attach()
	if not (attach_parent or player_api.player_attached[name]) then
		Body.y = Body.y - lag_behind
		Head.y = Head.y + lag_behind
		if interacting then Arm_Right.y = Arm_Right.y + lag_behind end
	else
		if attach_parent then
			local total_rotation = normalize_rotation(vector.add(attach_rotation, vector.apply(attach_parent:get_rotation(), math.deg)))

			local function rotate_relative(euler_rotation)
				-- HACK +180
				euler_rotation.y = euler_rotation.y + look_horizontal + 180
				local new_rotation = normalize_rotation(vector.add(euler_rotation, total_rotation))
				euler_rotation.x, euler_rotation.y, euler_rotation.z = new_rotation.x, new_rotation.y, new_rotation.z
			end

			rotate_relative(Head)
			if interacting then rotate_relative(Arm_Right) end
		end
	end

	Head.x = clamp(Head.x, unpack(conf.head.pitch))
	Head.y = clamp(Head.y, unpack(conf.head.yaw))
	if math.abs(Head.y) > conf.head.yaw_restriction then
		Head.x = clamp(Head.x, unpack(conf.head.yaw_restricted))
	end
	Arm_Right.y = clamp(Arm_Right.y, unpack(conf.arm_right.yaw))

	for bone, values in pairs(bone_positions) do
		player:set_bone_position(bone, values.position, values.euler_rotation)
	end
	player_animation.bone_positions = bone_positions
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		handle_player_animations(dtime, player)
	end
end)