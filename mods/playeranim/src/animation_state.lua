-- Avoiding global for performance
local table_remove = table.remove

local AnimationState = {
	time = function(self)
		return self.m_time
	end,

	time_increment = function(self, dtime)
		self.m_time = self.m_time + dtime
	end,

	time_reset = function(self)
		self.m_time = 0
	end,

	yaw_history_push_back = function(self, yaw)
		local history = self.m_yaw_history
		history[#history + 1] = yaw
	end,

	yaw_history_pop_front = function(self)
		return table_remove(self.m_yaw_history, 1)
	end,

	yaw_history_clear = function(self)
		self.m_yaw_history = {}
	end,

	yaw_history_length = function(self)
		return #self.m_yaw_history
	end,

	get_bone_rotation = function(self, bone)
		return self.m_bone_rotations[bone]
	end,

	set_bone_rotation = function(self, bone, rotation)
		self.m_bone_rotations[bone] = rotation
	end,

	get_bone_position = function(self, bone)
		return self.m_bone_positions[bone]
	end,

	set_bone_position = function(self, bone, position)
		self.m_bone_positions[bone] = position
	end,

	get_previous_animation = function(self)
		return self.m_previous_animation
	end,

	set_previous_animation = function(self, animation)
		self.m_previous_animation = animation
	end,
}

AnimationState.new = function()
	return setmetatable({
		m_time = 0,
		m_yaw_history = {},
		m_bone_rotations = {},
		m_bone_positions = {},
		m_previous_animation = nil,
	}, { __index = AnimationState })
end

return AnimationState
