-- See https://github.com/luanti-org/luanti/issues/15692

local mod = modlib.mod
local b3d = modlib.b3d

local media_paths = modlib.minetest.media.paths

local function is_perfect(quat)
	local mat = modlib.matrix4.rotation(quat)
	local diag_abs_sum = 0
	for i = 1, 3 do
		diag_abs_sum = diag_abs_sum + math.abs(mat[i][i])
	end
	return math.abs(diag_abs_sum - 3) < 1e-5
end

return function(name)
	local stream = assert(io.open(media_paths[name], "rb"))
	local character = assert(b3d.read(stream))
	stream:close()

	local function wiggle_rotation(quat)
		if math.abs(quat[1]) + math.abs(quat[2]) + math.abs(quat[3]) < 1e-5 then return quat end -- identity
		if not is_perfect(quat) then return quat end
		local wiggled = {}
		for i = 1, 4 do
			wiggled[i] = quat[i] + 1e-3
		end
		wiggled = modlib.quaternion.normalize(wiggled)
		if not is_perfect(wiggled) then return wiggled end
		for i = 1, 4 do
			wiggled[i] = quat[i] - 1e-3
		end
		wiggled = modlib.quaternion.normalize(wiggled)
		if not is_perfect(wiggled) then return wiggled end
		return quat -- this shouldn't happen
	end

	local function wiggle_rotations(node)
		node.rotation = wiggle_rotation(node.rotation)
		node.keys = {}
		for _, child in ipairs(node.children) do
			wiggle_rotations(child)
		end
	end

	wiggle_rotations(character.node)

	local rope = {}
	character:write({write = function(_, str)
		table.insert(rope, str)
	end})
	return table.concat(rope)
end
