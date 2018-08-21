--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
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


--- Various functions for rotating nodes.
-- 
-- The internal mechanics of Minetest are as follows: It uses the facedir value
-- to apply an rotation. It is value with the minimum of 0 (no rotation) to
-- the maximum of 23 (1 0 1 1 1). It consists of two parts, the lower two bits
-- are the amount of rotation applied:
--
--    Bits	Value	Description
--    0 0	0		No rotation
--    0 1	1		90 degrees (sign depending on axis, + for z+ x- y-)
--    1 0	2		180 degrees
--    1 1	3		-90 degrees (sign depending on axis, + for z- x+ y+)
-- 
-- These values correspond to the ROT_* constants.
-- 
-- The upper three bits are the axis that is used:
--
--    Bits	Value	Shifted	Description
--    0 0 0	0		0		y+, no rotation
--    0 0 1	1		4		z+, 90 degrees clockwise around x
--    0 1 0	2		8		z-, 90 degrees counter-clockwise around x
--    0 1 1	3		12		x+, 90 degrees counter-clockwise around z
--    1 0 0	4		16		x-, 90 degrees clockwise around z
--    1 0 1	5		20		y-, 180 degrees counter-clockwise around x
--
-- These values correspond to the POS_* and NEG_* constants.
--  
-- The rotation is a two step process, first the rotation of the axis/upper
-- three bits are applied, after that the rotation/lower two bits.
--
-- See the mapnode.cpp/transformNodeBox function for even more details.
rotationutil = {
	--- The negative X Axis. Will rotate the node around the Z axis by
	-- 90 degrees clockwise before the additional rotation is applied.
	--
	-- Minetest internal it has the value 4, within facedir it is 16 (1 0 0 R R).
	NEG_X = 16,
	--- The negative Z Axis. Will rotate the node around the X axis by
	-- 90 degrees counter-clockwise before the additional rotation is applied.
	--
	-- Minetest internal it has the value 2, within facedir it is 8 (0 1 0 R R).
	NEG_Z = 8,
	--- The negative Y Axis. Will rotate the node around the Z axis by
	-- 180 degrees counter-clockwise before the additional rotation is applied.
	--
	-- Minetest internal it has the value 5, within the bitmask of facedir it
	-- is 20 (1 0 1 R R).
	NEG_Y = 20,
	--- The positive X Axis. Will rotate the node around the Z axis by
	-- 90 degrees counter-clockwise before the additional rotation is applied.
	--
	-- Minetest internal it has the value 3, within facedir it is 12 (0 1 1 R R).
	POS_X = 12,
	--- The positive Y Axis. Will not rotate the node before the additional
	-- rotation is applied.
	--
	-- Minetest internal it has the value 0, within of facedir it is 0 (0 0 0 R R).
	POS_Y = 0,
	--- The positive Z Axis. Will rotate the node around the X axis by
	-- 90 degrees clockwise before the additional rotation is applied.
	--
	-- Minetest internal it has the value 1, within facedir it is 4 (0 0 1 R R).
	POS_Z = 4,
	--- No rotation.
	ROT_0 = 0,
	--- Rotation 90 degrees, sign depends on the axis.
	ROT_90 = 1,
	--- Rotation 180 degrees.
	ROT_180 = 2,
	--- Rotation 270/-90 degrees, sign depends on the axis.
	ROT_270 = 3
}


--- Returns the decremented rotation, so given rotation - 90 degrees.
--
-- @param rotation The rotation to decrement.
-- @return The decremented rotation, or the given value if it was not valid.
function rotationutil.decrement(rotation)
	if rotation == rotationutil.ROT_0 then
		return rotationutil.ROT_270
	elseif rotation == rotationutil.ROT_90 then
		return rotationutil.ROT_0
	elseif rotation == rotationutil.ROT_180 then
		return rotationutil.ROT_90
	elseif rotation == rotationutil.ROT_270 then
		return rotationutil.ROT_180
	end
	
	return rotation
end

--- Creates the facedir value from the given axis and rotation.
--
-- @param axis The axis, one of the POS_* or NEG_* constants.
-- @param rotation The rotation, one of the ROT_* constants.
-- @return The facedir value.
function rotationutil.facedir(axis, rotation)
	return axis + rotation
end

--- Returns the incremented rotation, so given rotation + 90 degrees.
--
-- @param rotation The rotation to increment.
-- @return The incremented rotation, or the given value if it was not valid.
function rotationutil.increment(rotation)
	if rotation == rotationutil.ROT_0 then
		return rotationutil.ROT_90
	elseif rotation == rotationutil.ROT_90 then
		return rotationutil.ROT_180
	elseif rotation == rotationutil.ROT_180 then
		return rotationutil.ROT_270
	elseif rotation == rotationutil.ROT_270 then
		return rotationutil.ROT_0
	end
	
	return rotation
end

--- Inverts the given axis or rotation.
-- @param axis_or_rotation The axis or rotation, one of the POS_*, NEG_* or
--                         ROT_* constants.
-- @return The inverted value, or the given value if it was not valid.
function rotationutil.invert(axis_or_rotation)
	if axis_or_rotation == rotationutil.NEG_X then
		return rotationutil.POS_X
	elseif axis_or_rotation == rotationutil.NEG_Y then
		return rotationutil.POS_Y
	elseif axis_or_rotation == rotationutil.NEG_Z then
		return rotationutil.POS_Z
	elseif axis_or_rotation == rotationutil.POS_X then
		return rotationutil.NEG_X
	elseif axis_or_rotation == rotationutil.POS_Y then
		return rotationutil.NEG_Y
	elseif axis_or_rotation == rotationutil.POS_Y then
		return rotationutil.NEG_Z
	end
	
	if axis_or_rotation == rotationutil.ROT_0 then
		return rotationutil.ROT_180
	elseif axis_or_rotation == rotationutil.ROT_90 then
		return rotationutil.ROT_270
	elseif axis_or_rotation == rotationutil.ROT_180 then
		return rotationutil.ROT_0
	elseif axis_or_rotation == rotationutil.ROT_270 then
		return rotationutil.ROT_90
	end
	
	return axis_or_rotation
end

