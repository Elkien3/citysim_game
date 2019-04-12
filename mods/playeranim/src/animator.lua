-- Avoiding global for performance
local pairs, ipairs, math_abs, vector_new, vector_add, vector_apply, vector_equals, minetest_get_connected_players =
		pairs, ipairs, math.abs, vector.new, vector.add, vector.apply, vector.equals, minetest.get_connected_players

local AnimationState = require("animation_state")

local function rotation_interpolate(e, s, q)
	-- https://stackoverflow.com/a/14498790
	local interpolated = ((((e - s) % 360) + 540) % 360) - 180
	if math_abs(interpolated) then
		return e + interpolated / q
	else
		return e
	end
end

local function vector_interpolate(new, old)
	return vector_new({
		x = rotation_interpolate(new.x, old.x, 2),
		y = rotation_interpolate(new.y, old.y, 2),
		z = rotation_interpolate(new.z, old.z, 2),
	})
end

local Animator = {
	animate = function(self, yaw, dtime)
		local animations = self.m_model:animations()
		for index, animation in ipairs(animations) do
			if animation.condition(self.m_object) then
				self:_set_animation(yaw, dtime, animation, index)
				break
			end
		end
	end,

	yaw_history_clear = function(self)
		self.m_state:yaw_history_clear()
	end,

	_set_animation = function(self, yaw, dtime, animation_def, animation_index)
		local state = self.m_state
		local delayed_yaw = self:_delayed_yaw(yaw)

		if animation_def.option.use_time then
			self.m_state:time_increment(dtime)
		else
			self.m_state:time_reset()
		end

		local force_update = animation_def.option.force_update or self.m_model:interpolation()
		local is_animation_changed = self.m_state:get_previous_animation() ~= animation_index
		if force_update or is_animation_changed then
			self.m_state:set_previous_animation(animation_index)
			self:_apply_bones(
					self:_bones(animation_def, delayed_yaw),
					force_update)
		end
	end,

	_delayed_yaw = function(self, yaw)
		self.m_state:yaw_history_push_back(yaw)

		local length = self.m_state:yaw_history_length()
		local delay_frames = self.m_model:delayed_yaw_frames()

		if length > delay_frames then
			return yaw - self.m_state:yaw_history_pop_front()
		else
			return 0
		end
	end,

	_bones = function(self, animation_def, delayed_yaw)
		local bones = self.m_model:bones()
		local object = self.m_object
		local time = self.m_state:time()
		return animation_def.animation(bones, object, time, delayed_yaw):unwrap()
	end,

	_apply_bones = function(self, bones, force_update)
		for bone, data in pairs(bones) do
			local rotation = data.rotation
			local position = data.position
			local interpolation = force_update and self.m_model:interpolation()
			self:_apply_bone(bone, rotation, position, interpolation)
		end
	end,

	_apply_bone = function(self, bone, rotation, position, interpolation)
		local previous_rotation = self.m_state:get_bone_rotation(bone)
		local previous_position = self.m_state:get_bone_position(bone)

		if not previous_rotation
		or not previous_position
		or not vector_equals(rotation, previous_rotation)
		or not vector_equals(position, previous_position) then
			if interpolation and previous_rotation then
				rotation = vector_interpolate(rotation, previous_rotation)
			end
			self.m_state:set_bone_rotation(bone, rotation)
			self.m_state:set_bone_position(bone, position)
			self.m_object:set_bone_position(bone, position, rotation)
		end
	end,
}

Animator.new = function(object, model)
	return setmetatable({
		m_state = AnimationState.new(),
		m_model = model,
		m_object = object,
	}, { __index = Animator })
end

return Animator
