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


--- Various functions related to blocks/chunks.
blockutil = {
	--- The size of one block in nodes.
	BLOCK_SIZE = 16,
	
	--- The size of a mapchunk in blocks.
	MAPCHUNK_IN_BLOCKS_SIZE = 5,
	
	--- The size of one mapchunk in nodes.
	MAPCHUNK_SIZE = 80,
	
	--- The size of one node.
	NODE_SIZE = 1
}


--- Gets the begin coordinates of the block the given coordinates are in.
--
-- @param x The x coordinate. Can also be a table with the x, y and z values.
-- @param y The y coordinate.
-- @param z The z coordinate.
-- @return The coordinates (x, y, z) of the blocks begin.
function blockutil.get_begin(x, y, z)
	if type(x) == "table" then
		local pos = x
		
		x = pos.x
		y = pos.y
		z = pos.z
	end
	
	if y == nil and z == nil then
		local begin = x
		
		if begin >= 48 then
			local difference = math.fmod(begin + 32, 80)
			begin = begin - difference
		elseif begin >= -32 then
			return -32
		else
			local difference = math.fmod(math.abs(begin + 32), 80)
			
			if difference > 0 then
				difference = 80 - difference
			end
			
			begin = begin - difference
		end
		
		return begin
	end
	
	return blockutil.get_begin(x), blockutil.get_begin(y), blockutil.get_begin(z)
end

--- Gets the begin coordinates of the block the given coordinates are in
-- as position (a table with three entries, x, y, and z).
--
-- @param x The x coordinate. Can also be a table with the x, y and z values.
-- @param y The y coordinate.
-- @param z The z coordinate.
-- @return The coordinates (x, y, z) of the blocks begin as pos.
function blockutil.get_begin_pos(x, y, z)
	local begin_x, begin_y, begin_z = blockutil.get_begin(x, y, z)
	
	return {
		x = begin_x,
		y = begin_y,
		z = begin_z
	}
end

--- Gets the end coordinates of the block the given coordinates are in.
--
-- @param x The x coordinate. Can also be a table with the x, y and z values.
-- @param y The y coordinate.
-- @param z The z coordinate.
-- @return The coordinates (x, y, z) of the blocks end.
function blockutil.get_end(x, y, z)
	if type(x) == "table" then
		local pos = x
		
		x = pos.x
		y = pos.y
		z = pos.z
	end
	
	if y == nil and z == nil then
		return blockutil.get_begin(x + constants.block_size) - 1
	end
	
	return blockutil.get_end(x), blockutil.get_end(y), blockutil.get_end(z)
end

--- Gets the end coordinates of the block the given coordinates are in
-- as position (a table with three entries, x, y, z).
--
-- @param x The x coordinate. Can also be a table with the x, y and z values.
-- @param y The y coordinate.
-- @param z The z coordinate.
-- @return The coordinates (x, y, z) of the blocks end as pos.
function blockutil.get_end_pos(x, y, z)
	local end_x, end_y, end_z = blockutil.get_end(x, y, z)
	
	return {
		x = end_x,
		y = end_y,
		z = end_z
	}
end

