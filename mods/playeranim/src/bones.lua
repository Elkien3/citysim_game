-- Avoiding global for performance
local table_copy, getmetatable, setmetatable, vector_add, vector_new =
		table.copy, getmetatable, setmetatable, vector.add, vector.new

local Bones = {}

local impl = function(self, bone_or_method)
	if bone_or_method == "unwrap" then
		local bones = table_copy(self.bones_modified)
		return function()
			return bones
		end
	end

	if bone_or_method == "clone" then
		local cloned_self = table_copy(self)
		local metatable = getmetatable(self)
		return function()
			return setmetatable(cloned_self, metatable)
		end
	end

	if bone_or_method == "reset" then
		local self = self.clone()
		return function(bone)
			self.bones_modified[bone] = table_copy(self.bones_original[bone])
			return self
		end
	end

	local bone = bone_or_method
	if self.bones_modified[bone] then
		local self = self.clone()
		return function(rotation, position_optional)
			local data = self.bones_modified[bone]
			self.bones_modified[bone] = {
				position = vector_add(data.position, vector_new(position_optional)),
				rotation = vector_add(data.rotation, rotation),
			}
			return self
		end
	end

	return nil
end

Bones.new = function(bones_map)
	return setmetatable({
		bones_original = table_copy(bones_map),
		bones_modified = table_copy(bones_map),
	}, { __index = impl })
end

return Bones
