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


--- The MapManipulator is a thin wrapper around the VoxelManip object
-- provided by minetest. It only capsules the VoxelManip and VoxelArea behind
-- a few functions to minimize code.
MapManipulator = {}


--- Creates a new instance of MapManipulator.
--
-- The parameters only need to be used if you want to read from a certain
-- area of the map. They are not needed if called from on_generated function.
--
-- @param minp Optional. The minimum point to read the data from.
-- @param maxp Optional. The maximum point to read the data from.
-- @return A new instance.
function MapManipulator:new(minp, maxp)
	local instance = {
		area = nil,
		data = nil,
		emax = nil,
		emin = nil,
		param2_data = nil,
		voxelmanip = nil
	}
	
	if minp == nil and maxp == nil then
		instance.voxelmanip, instance.emin, instance.emax = minetest.get_mapgen_object("voxelmanip")
	else
		instance.voxelmanip = minetest.get_voxel_manip()
		instance.emin = minp
		instance.emax = maxp
		instance.voxelmanip:read_from_map(instance.emin, instance.emax)
	end
	
	instance.area = VoxelArea:new({
		MinEdge = instance.emin,
		MaxEdge = instance.emax
	})
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets the VoxelArea for the current VoxelManip.
--
-- @return The VoxelArea.
function MapManipulator:get_area()
	return self.area
end

--- Gets the data from the VoxelManip object.
-- The data is an array that can be accessed by using the VoxelArea object.
--
-- @return Two values, the data and the param2 data.
function MapManipulator:get_data()
	if self.data == nil then
		self.data = self.voxelmanip:get_data()
		self.param2_data = self.voxelmanip:get_param2_data()
	end
	
	return self.data, self.param2_data
end

--- Gets the node and param2 at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @return Two values, the node at the given location and the param2 value.
function MapManipulator:get_node(x, z, y)
	if self.data == nil then
		self.data = self.voxelmanip:get_data()
		self.param2_data = self.voxelmanip:get_param2_data()
	end
	
	local index = self.area:index(x, y, z)
	
	return self.data[index], self.param2_data[index]
end

--- Sets the data into the VoxelManip object.
-- Will also correct and update the lighting, the liquids and flush the map.
--
-- @param data Optional. The data to set. If nil the cached data will be used.
-- @param param2_data Optional. The param2 data to set. If nil the cached data
--                    will be used.
function MapManipulator:set_data(data, param2_data)
	if data == nil and self.data == nil then
		return
	end
	
	self.voxelmanip:set_data(data or self.data)
	self.voxelmanip:set_param2_data(param2_data or self.param2_data)
	
	self.voxelmanip:set_lighting({
		day = 1,
		night = 0
	})
	self.voxelmanip:calc_lighting()
	self.voxelmanip:update_liquids()
	self.voxelmanip:write_to_map()
	self.voxelmanip:update_map()
	
	self.data = nil
	self.param2_data = nil
end

--- Sets the node at the given location.
--
-- @param x The x coordinate (width).
-- @param z the z coordinate (depth).
-- @param y The y coordinate (height).
-- @param node The node to set.
-- @param param2 Optional. The param2 data to set for this node.
function MapManipulator:set_node(x, z, y, node, param2)
	if self.data == nil then
		self.data = self.voxelmanip:get_data()
		self.param2_data = self.voxelmanip:get_param2_data()
	end
	
	local index = self.area:index(x, y, z)
	
	self.data[index] = node
	self.param2_data[index] = param2
end

