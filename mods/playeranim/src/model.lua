-- This is used in only compile-time, so no need to optimize performances (such as avoiding global)

local Bones = require("bones")

local Model_impl = {
	validate = function(self) --> bool
		assert(type(self) == "table")
		assert(type(self.m_bones) == "table")
		assert(type(self.m_animations) == "table")
		assert(type(self.m_delayed_yaw_frames) == "number")

		for i, animation in pairs(self.m_animations) do
			assert(type(i) == "number")
			assert(type(animation) == "table")
			assert(type(animation.condition) == "function")
			assert(type(animation.animation) == "function")
			assert(type(animation.option) == "table")
		end

		for bone, data in pairs(self.m_bones) do
			assert(type(bone) == "string")
			assert(type(data) == "table")
			assert(type(vector.new(data.rotation)) == "table")
			assert(type(vector.new(data.position)) == "table")
		end

		return true
	end,

	unwrap = function(self) --> Self
		self:validate()
		return self
	end,

	target = function(self) --> String
		return self.m_target
	end,

	bones = function(self) --> Bones
		return Bones.new(self.m_bones)
	end,

	animations = function(self)
		return table.copy(self.m_animations)
	end,

	delayed_yaw_frames = function(self) --> Number
		return self.m_delayed_yaw_frames
	end,

	set_delayed_yaw_frames = function(self, delayed_yaw_frames) --> Self
		self.m_delayed_yaw_frames = delayed_yaw_frames
		return self
	end,

	interpolation = function(self) --> bool
		return self.m_interpolation
	end,

	set_interpolation = function(self, interpolation) --> Self
		self.m_interpolation = interpolation
		return self
	end,

	-- bone: String
	-- standard_position: Vector
	-- standard_rotation: Vector
	register_bone = function(self, bone, standard_rotation, standard_position)
		do
			assert(bone ~= "unwrap"
					and bone ~= "clone"
					and bone ~= "reset")
			assert(type(bone) == "string")
			assert(type(vector.new(standard_rotation)) == "table")
			assert(type(vector.new(standard_position)) == "table")
		end

		if self.m_bones[bone] then
			minetest.log("warning", "Model:register_bone: Bone \"" .. bone .. "\" is already registered, override.")
		end

		self.m_bones[bone] = {
			rotation = standard_rotation,
			position = standard_position,
		}

		return self
	end,

	-- condition_func: Function(object: ObjectRef) -> Boolean
	-- animation_func: Function(
	-- 		bones: { [bone: String] = Function(rotation: Vector, position_optional: Vector or Nil) },
	-- 		object: ObjectRef,
	-- 		time: Number,
	-- 		delayed_yaw: Number
	-- )
	-- option: {
	-- 	use_time: Boolean,
	-- 	force_update: Boolean,
	-- 	clear_yaw_history: Boolean,
	-- }
	register_animation = function(self, condition_func, animation_func, option)
		option = option or {}

		do
			assert(type(condition_func) == "function")
			assert(type(animation_func) == "function")
			assert(type(option) == "table")
		end

		table.insert(self.m_animations, {
			condition = condition_func,
			animation = animation_func,
			option = option,
		})

		return self
	end,
}

local Model = {}

Model.new = function(target)
	do
		assert(target == "all"
				or target == "player"
				or target == "entity")
	end

	return setmetatable(table.copy({
		m_target = target,
		m_bones = {},
		m_animations = {},
		m_delayed_yaw_frames = 0,
		m_interpolation = false,
	}), { __index = Model_impl })
end

return Model
