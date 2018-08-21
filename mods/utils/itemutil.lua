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


--- Provides various utility functions for working with items.
itemutil = {
	--- The split mode for randomly splitting the stack.
	SPLIT_MODE_RANDOM = "random",
	
	--- The split mode for splitting the stack into single items.
	SPLIT_MODE_SINGLE = "single",
	
	--- The split mode for preserving the complete stack.
	SPLIT_MODE_STACK = "stack"
}


--- "Blops" the item into existence at the given position and assigns it
-- a random velocity/acceleration.
--
-- @param position_or_object The position, a pos value or an ObjectRef.
-- @param itemstrings_or_stacks The item string or an ItemStack.
-- @param x_strength Optional. The strength of the random movement in
--                   the x direction, defaults to 5.
-- @param y_strength Optional. The strength o the random movement in
--                   the y direction, defaults to 5, minimum is 1.
-- @param z_strength Optional. The strength of the random movement in
--                   the z direction, defaults to 5.
-- @param split_mode Optional. The mode for splitting the items, defaults
--                   to SPLIT_MODE_STACK.
-- @return The spawned items in a List.
function itemutil.blop(position_or_object, itemstrings_or_stacks, x_strength, y_strength, z_strength, split_mode)
	x_strength = x_strength or 5
	y_strength = math.max(y_strength or 5, 1)
	z_strength = z_strength or 5
	split_mode = split_mode or itemutil.SPLIT_MODE_STACK
	
	local position = position_or_object
	if type(position.getpos) == "function" then
		position = position:getpos()
	end
	
	local itemstrings = List:new()
	
	if type(itemstrings_or_stacks) == "table" then
		for index, itemstring_or_stack in ipairs(itemstrings_or_stacks) do
			itemstrings:add_list(itemutil.split(itemstring_or_stack, split_mode))
		end
	else
		itemstrings:add_list(itemutil.split(itemstrings_or_stacks, split_mode))
	end
	
	local spawned_items = List:new()
	
	itemstrings:foreach(function(itemstring, index)
		local spawned_item = minetest.add_item(position, itemstring)
		
		if spawned_item ~= nil then
			spawned_item:setvelocity({
				x = random.next_float(-x_strength, x_strength),
				y = random.next_float(1, y_strength),
				z = random.next_float(-z_strength, z_strength)
			})
			
			spawned_items:add(spawned_item)
		end
	end)
	
	return spawned_items
end

--- Gets the item string from the given item.
--
-- @param item The item for which to get the item string.
-- @return The item string, or nil.
function itemutil.get_itemstring(item)
	if item ~= nil then
		if type(item) == "string" then
			return item
		elseif type(item.to_string) == "function" then
			return item:to_string()
		end
	end
	
	return nil
end

--- Splits the given item stack according to the provided method.
--
-- @param itemstring_or_itemstack The item string or ItemStack to split.
-- @param split_mode The split mode.
-- @return A List of item strings, an empty List it could not be split.
function itemutil.split(itemstring_or_itemstack, split_mode)
	if split_mode == itemutil.SPLIT_MODE_RANDOM then
		return itemutil.split_random(itemstring_or_itemstack)
	elseif split_mode == itemutil.SPLIT_MODE_SINGLE then
		return itemutil.split_single(itemstring_or_itemstack)
	elseif split_mode == itemutil.SPLIT_MODE_STACK then
		return List:new(itemutil.get_itemstring(itemstring_or_itemstack))
	end
	
	return List:new()
end

--- Splits the given item stack randomly.
--
-- @param itemstring_or_itemstack The item string or ItemStack to split
--                                randomly.
-- @return The List of item strings.
function itemutil.split_random(itemstring_or_itemstack)
	local stack = ItemStack(itemstring_or_itemstack)
	
	local itemstrings = List:new()
	
	local name = stack:get_name()
	local remaining = stack:get_count()
	
	while remaining > 0 do
		local count = random.next_int(1, remaining)
		local itemstring = name .. " " .. tostring(count)
		
		itemstrings:add(itemstring)
		
		remaining = remaining - count;
	end
	
	return itemstrings
end

--- Splits the given item stack into single items.
--
-- @param itemstring_or_itemstack The item string or ItemStack to split
--                                into single items.
-- @return The List of item strings.
function itemutil.split_single(itemstring_or_itemstack)
	local stack = ItemStack(itemstring_or_itemstack)
	
	local itemstrings = List:new()
	
	local name = stack:get_name()
	
	for counter = 1, stack:get_count(), 1 do
		itemstrings:add(name)
	end
	
	return itemstrings
end

