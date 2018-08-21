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


--- The ArrayManipulator is similiar to the MapManipulator, except that it
-- does not use the VoxelManip object, but has an internal array which contains
-- all set values. It is mostly compatible with MapManipulator, which means you
-- can pass it to functions which expect a MapManipulator.
ArrayManipulator = {}


--- Creates a new instance of ArrayManipulator.
--
-- @param node_data The array that contains the values for the nodes part. This
--                  is assumed to be a 3d array with x, z, and y values
--                  as dimensions.
-- @param param2_data The array that contains the values for the param2 part.
--                    This is assumed to be a 3d array with x, z, and y values
--                    as dimensions.
-- @return A new instance.
function ArrayManipulator:new(node_data, param2_data)
	local instance = {
		node_data = node_data,
		param2_data = param2_data
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end

--- Does nothing, only for compatibility with MapManipulator.
function ArrayManipulator:get_data()
	-- Nothing.
end

--- Gets the node and param2 at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @return Two values, the node at the given location and the param2 value.
function ArrayManipulator:get_node(x, z, y)
	return self.node_data[x][z][y], self.param2_data[x][z][y]
end

--- Does nothing, only for compatibility with MapManipulator.
function ArrayManipulator:set_data()
	-- Nothing.
end

--- Sets the node at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @param node The node to set.
-- @param param2 Optional. The param2 data to set for this node.
function ArrayManipulator:set_node(x, z, y, node, param2)
	self.node_data[x][z][y] = node
	self.param2_data[x][z][y] = param2
end

