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


--- Various functions related to nodes.
nodeutil = {}


--- Gets the content id of the given node.
--
-- @param node The node, can either be an id, a name or a table with the name.
-- @return The content id of the given node.
function nodeutil.get_id(node)
	if type(node) == "string" then
		return minetest.get_content_id(node)
	elseif type(node) == "table" then
		return minetest.get_content_id(node.name)
	end
	
	return node
end

--- Gets the name of given node.
--
-- @param node The node, can either be an id, a name or a table with the name.
-- @return The name of the given node.
function nodeutil.get_name(node)
	if type(node) == "number" then
		return minetest.get_name_from_content_id(node)
	elseif type(node) == "table" then
		return node.name
	end
	
	return node
end

--- Checks if the given node has the given group.
--
-- @param node The node to check.
-- @param group_name The name of the group.
-- @return true if the node has the given group.
function nodeutil.has_group(node, group_name)
	local node_name = nodeutil.get_name(node)
	
	return minetest.get_item_group(node_name, group_name) > 0
end

--- Checks if the given node is walkable.
--
-- @param node The node to check, can either be an id, a name or a table with
--             the name.
-- @return true if the given node is walkable.
function nodeutil.is_walkable(node)
	local node_name = nodeutil.get_name(node)
	local node_definition = minetest.registered_nodes[node_name]
	
	if node_definition ~= nil then
		-- Test against false needed in case that walkable is not set,
		-- as it defaults to true.
		return node_definition.walkable ~= false
	end
	
	-- The node does not exist, sad.
	return false
end

--- Iterates over the surroundings of the given position and invokes
-- the callback for every node in the surroundings.
--
-- For example if you want to iterate over the direct neighbourse in all
-- dimensions, you'd do the following:
--
--    nodeutil.surroundings(pos, -1, 1, -1, 1, -1, 1, callback)
--
-- @param pos The position that is the center.
-- @param x_begin The modifier for the beginning in the x dimension.
-- @param x_end The modifier for the end in the x dimension.
-- @param z_begin The modifier for the beginning in the z dimension.
-- @param z_end The modifier for the end in the z dimension.
-- @param y_begin The modifier for the beginning in the y dimension.
-- @param y_end The modifier for the end in the y dimension.
-- @param callback The callback to invoke for every surrounding node. can
--                 return true if iterating over the surroundings should be
--                 stopped.
-- @return true if the iterating over the surroundings has been stopped by
--         a callback.
function nodeutil.surroundings(pos, x_begin, x_end, z_begin, z_end, y_begin, y_end, callback)
	for x = pos.x + x_begin, pos.x + x_end, 1 do
		for z = pos.z + z_begin, pos.z + z_end, 1 do
			for y = pos.y + y_begin, pos.y + y_end, 1 do
				if x ~= pos.x or z ~= pos.z or y ~= pos.y then
					local current_pos = {
						x = x,
						y = y,
						z = z
					}
					
					if callback(current_pos, minetest.get_node(current_pos)) then
						return true
					end
				end
			end
		end
	end
	
	return false
end

