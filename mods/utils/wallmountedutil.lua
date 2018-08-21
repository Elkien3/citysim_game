--[[
Copyright (c) 2014, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- Various functions and constants for working with the wallmounted
-- value.
wallmountedutil = {
	--- Attached to the node in the negative x direction.
	NEGATIVE_X = 3,
	
	--- Attached to the node in the negative y direction.
	NEGATIVE_Y = 1,
	
	--- Attached to the node in the negative z direction.
	NEGATIVE_Z = 5,
	
	--- The vector for the negative x direction.
	NEGATIVE_X_VECTOR = {
		x = -1,
		y = 0,
		z = 0
	},
	
	--- The vector for the negative y direction.
	NEGATIVE_Y_VECTOR = {
		x = 0,
		y = -1,
		z = 0
	},
	
	--- The vector for the negative z direction.
	NEGATIVE_Z_VECTOR = {
		x = 0,
		y = 0,
		z = -1
	},
	
	--- Attached to the node in the positive y direction.
	POSITIVE_X = 2,
	
	--- Attached to the node in the positive y direction.
	POSITIVE_Y = 0,
	
	--- Attached to the node in the positive y direction.
	POSITIVE_Z = 4,
	
	--- The vector for the positive x direction.
	POSITIVE_X_VECTOR = {
		x = 1,
		y = 0,
		z = 0
	},
	
	--- The vector for the positive y direction.
	POSITIVE_Y_VECTOR = {
		x = 0,
		y = 1,
		z = 0
	},
	
	--- The vector for the positive z direction.
	POSITIVE_Z_VECTOR = {
		x = 0,
		y = 0,
		z = 1
	}
}


--- Gets the vector for the given ID.
--
-- @param id The ID for which to get the vector.
-- @return The vector for the given ID.
function wallmountedutil.get_vector(id)
	if id == wallmountedutil.NEGATIVE_X then
		return wallmountedutil.NEGATIVE_X_VECTOR
	elseif id == wallmountedutil.NEGATIVE_Y then
		return wallmountedutil.NEGATIVE_Y_VECTOR
	elseif id == wallmountedutil.NEGATIVE_Z then
		return wallmountedutil.NEGATIVE_Z_VECTOR
	elseif id == wallmountedutil.POSITIVE_X then
		return wallmountedutil.POSITIVE_X_VECTOR
	elseif id == wallmountedutil.POSITIVE_Y then
		return wallmountedutil.POSITIVE_Y_VECTOR
	elseif id == wallmountedutil.POSITIVE_Z then
		return wallmountedutil.POSITIVE_Z_VECTOR
	end
	
	return wallmountedutil.NEGATIVE_Y_VECTOR
end

--- Gets the corresponding facedir value for the given wallmounted value.
--
-- @param wallmounted_id The wallmounted value/ID.
-- @return The facedir value/ID.
function wallmountedutil.to_facedir(wallmounted_id)
	if wallmounted_id == wallmountedutil.NEGATIVE_X then
		return facedirutil.NEGATIVE_X
	elseif wallmounted_id == wallmountedutil.NEGATIVE_Z then
		return facedirutil.NEGATIVE_Z
	elseif wallmounted_id == wallmountedutil.POSITIVE_X then
		return facedirutil.POSITIVE_X
	elseif wallmounted_id == wallmountedutil.POSITIVE_Z then
		return facedirutil.POSITIVE_Z
	end
	
	return facedirutil.POSITIVE_X
end


