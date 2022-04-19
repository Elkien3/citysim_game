modeldata = minetest.deserialize(modlib.file.read(modlib.mod.get_resource"modeldata.lua"))

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
	return modlib.vector.interpolate(prev_value, next_value, ratio)
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

function set_bone_override(player, bonename, position, rotation)
	local name = player:get_player_name()
	local value = {
		position = position,
		euler_rotation = rotation
	}
	-- TODO consider setting empty overrides to nil
	players[name].bone_positions[bonename] = value
end

-- Raw PlayerRef.set_bone_position
local set_bone_position
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
	if not set_bone_position then
		local PlayerRef = getmetatable(player)
		set_bone_position = PlayerRef.set_bone_position
		function PlayerRef:set_bone_position(bonename, position, rotation)
			if self:is_player() then
				set_bone_override(self, bonename or "", position or {x = 0, y = 0, z = 0}, rotation or {x = 0, y = 0, z = 0})
			end
			return set_bone_position(self, bonename, position, rotation)
		end
	end
end)

minetest.register_on_leaveplayer(function(player) players[player:get_player_name()] = nil end)

local function disable_animation(player)
	return player:set_animation({x = 0, y = 0}, 0, 0, false)
end

local function clamp(value, range)
	if value > range.max then
		return range.max
	end
	if value < range.min then
		return range.min
	end
	return value
end

local function normalize_angle(angle)
	return ((angle + 180) % 360) - 180
end

local function normalize_rotation(euler_rotation)
	return vector.apply(euler_rotation, normalize_angle)
end

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
	if range_min == range_max then
		keyframe = range_min
	elseif frame_loop then
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
			euler_rotation = vector.subtract(quaternion.to_euler_rotation(absolute_rotation), values.euler_rotation)
		else
			euler_rotation = quaternion.to_euler_rotation(rotation)
		end
		bone_positions[bone] = {position = position, rotation = rotation, euler_rotation = euler_rotation}
	end
	local Body, Head, Arm_Right = bone_positions.Body.euler_rotation, bone_positions.Head.euler_rotation, bone_positions.Arm_Right.euler_rotation
	local look_vertical = -math.deg(player:get_look_vertical())
	Head.x = look_vertical
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
	-- TODO properly handle eye offset & height vs. actual head position
	if attach_parent then
		local parent_rotation = attach_parent:get_rotation()
		if attach_rotation and parent_rotation then
			parent_rotation = vector.apply(parent_rotation, math.deg)
			local total_rotation = normalize_rotation(vector.subtract(parent_rotation, attach_rotation))
			local function rotate_relative(euler_rotation)
				-- HACK +180
				euler_rotation.y = euler_rotation.y + look_horizontal + 180
				local new_rotation = normalize_rotation(vector.add(euler_rotation, total_rotation))
				modlib.table.add_all(euler_rotation, new_rotation)
			end

			rotate_relative(Head)
			if interacting then rotate_relative(Arm_Right) end
		end
	elseif not player_api.player_attached[name] then
		Body.y = Body.y - lag_behind
		Head.y = Head.y + lag_behind
		if interacting then Arm_Right.y = Arm_Right.y + lag_behind end
	end

	-- HACK assumes that Body is root & parent bone of Head, only takes rotation around X-axis into consideration
	Head.x = normalize_angle(Head.x + Body.x)
	if interacting then Arm_Right.x = normalize_angle(Arm_Right.x + Body.x) end

	Head.x = clamp(Head.x, conf.head.pitch)
	Head.y = clamp(Head.y, conf.head.yaw)
	if math.abs(Head.y) > conf.head.yaw_restriction then
		Head.x = clamp(Head.x, conf.head.yaw_restricted)
	end
	Arm_Right.y = clamp(Arm_Right.y, conf.arm_right.yaw)
	
	if spriteguns and spriteguns.is_wielding_gun(name) then
		local tempvertlook = math.rad(look_vertical)
		local Rightval = vector.multiply(vector.dir_to_rotation(vector.rotate({x=0,y=0,z=1}, {x=tempvertlook,y=0,z=0})), 180/math.pi)
		Rightval.x = Rightval.x + 85
		bone_positions.Arm_Right.euler_rotation = Rightval
		bone_positions.Arm_Right.position.x = bone_positions.Arm_Right.position.x + .9
		local Leftval = vector.multiply(vector.dir_to_rotation(vector.rotate({x=-.8,y=0,z=1}, {x=tempvertlook,y=0,z=0})), 180/math.pi)
		Leftval.x = Leftval.x + 85
		bone_positions.Arm_Left.euler_rotation = Leftval
		bone_positions.Arm_Left.position.x = bone_positions.Arm_Left.position.x - .9
	end
	
	for bone, values in pairs(bone_positions) do
		local overridden_values = player_animation.bone_positions[bone]
		overridden_values = overridden_values or {}
		set_bone_position(player, bone, overridden_values.position or values.position, overridden_values.euler_rotation or values.euler_rotation)
	end
end

if player_api then
	-- TODO prevent player_api from using player:set_animation
	local set_animation = player_api.set_animation
	player_api.set_animation = function(player, ...)
		local player_animation = players[player:get_player_name()]
		if not player_animation then
			return
		end
		local ret = {set_animation(player, ...)}
		handle_player_animations(0, player)
		return unpack(ret)
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		handle_player_animations(dtime, player)
	end
end)