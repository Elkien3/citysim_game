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


--- The DirectMapManipulator is similiar to the MapManipulator, except that it
-- does not use the VoxelManip object, but the Minetest get_node/set_node
-- functions. It is mostly compatible with MapManipulator, which means you can
-- pass it to functions which expect a MapManipulator.
DirectMapManipulator = {
	instance = nil
}


function DirectMapManipulator.get_instance()
	if DirectMapManipulator.instance == nil then
		DirectMapManipulator.instance = DirectMapManipulator:new()
	end
	
	return DirectMapManipulator.instance
end

--- Creates a new instance of DirectMapManipulator.
--
-- @return A new instance.
function DirectMapManipulator:new()
	local instance = {}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end

--- Does nothing, only for compatibility with MapManipulator.
function DirectMapManipulator:get_data()
	-- Nothing.
end

--- Gets the node and param2 at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @return Two values, the node at the given location and the param2 value.
function DirectMapManipulator:get_node(x, z, y)
	local node = minetest.get_node({
		x = x,
		y = y,
		z = z
	})
	
	local id = minetest.get_content_id(node.name)
	
	return id, node.param2
end

--- Does nothing, only for compatibility with MapManipulator.
function DirectMapManipulator:set_data()
	-- Nothing.
end

--- Sets the node at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @param node The node to set.
-- @param param2 Optional. The param2 data to set for this node.
function DirectMapManipulator:set_node(x, z, y, node, param2)
	minetest.set_node({
		x = x,
		y = y,
		z = z
	}, {
		name = minetest.get_name_from_content_id(node),
		param2 = param2
	})
end

