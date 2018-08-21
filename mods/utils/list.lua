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


--- A simple list that keeps the order in which the items are added to it.
--
-- It is a thin wrapper around a simple, number indexed table providing
-- various convenience methods.
List = {
	--- An accept function that only accepts non nil values.
	--
	-- @param value The value that is checked.
	-- @return true if the given value is not nil.
	ACCEPT_NON_NIL = function(value)
		return value ~= nil
	end,
	
	--- An accept function that only accepts non empty string values.
	--
	-- @param value The value that is checked.
	-- @return true if the given value is a not empty string value.
	ACCEPT_NON_EMPTY_STRING = function(value)
		return type(value) == "string" and #value > 0
	end
}


--- Creates a new instance of List.
--
-- @param ... Optional. A list of values to add.
-- @return A new instance of List.
function List:new(...)
	local instance = {
		counter = 1
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	instance:add(...)
	
	return instance
end


--- Adds the given items to the list.
--
-- @param ... The items to add.
function List:add(...)
	for index, value in ipairs({...}) do
		self[self.counter] = value
		self.counter = self.counter + 1
	end
end

--- Adds the given List to the list.
--
-- @param ... The Lists to add.
function List:add_list(...)
	for index, list in ipairs({...}) do
		list:foreach(function(value, value_index)
			self:add(value)
		end)
	end
end

--- Clears all entries from the list.
function List:clear()
	for index = 1, self.counter - 1, 1 do
		self[index] = nil
	end
	
	self.counter = 1
end

--- Checks if this list contains the given item.
--
-- @param item The item to search for.
-- @return true if this list contains the given item.
function List:contains(item)
	return self:index(item) >= 0
end

--- Culls/removes all duplicates from this list.
--
-- @param comparator Optional. The comparator to be used. Accepts two values
--                   and returns true if they can be considered equal. Defaults
--                   to testing the identity.
function List:cull_duplicates(comparator)
	comparator = comparator or function(a, b)
		return a == b
	end
	
	-- Find duplicates.
	for index = 1, self.counter - 1, 1 do
		local value = self[index]
		
		if value ~= nil then
			for sec_index = index + 1, self.counter - 1, 1 do
				if comparator(self[sec_index], value) then
					self[sec_index] = nil
				end
			end
		end
	end
	
	-- Compact the list.
	local last_index = 1
	for index = 1, self.counter - 1, 1 do
		local value = self[index]
		
		if value ~= nil then
			self[last_index] = value
			last_index = last_index + 1
		end
	end
	
	-- Remove trailing elements.
	for index = last_index, self.counter - 1, 1 do
		self[index] = nil
	end
	
	self.counter = last_index
end

--- Iterates over all items in the list and invokes the given action on them.
--
-- @param action The function to invoke on the item, the first parameter will be
--               the item itself, the second (optional) parameter is the index.
--               The function can return true to stop iterating over the items.
function List:foreach(action)
	for index = 1, self.counter - 1, 1 do
		if action(self[index], index) == true then
			return
		end
	end
end

--- Gets the item at the given index. Returns nil if there is no item.
-- Note that there is no different between "no item" and "nil is the item",
-- in both cases nil is returned.
--
-- @param index The index of the item to get.
-- @return The item at the given index. nil if there is no item.
function List:get(index)
	return self[index]
end

--- Gets the first value in this List that is accepted by the given function.
--
-- @param accept Optional. The function to accept values. Accepts the value and
--               returns a boolean, true if the value is accepted. If nil
--               the first value in the list will be returned.
-- @return The first accepted value, or if none was accepted, nil.
function List:get_first(accept)
	for index = 1, self.counter - 1, 1 do
		if accept == nil or accept(self[index]) then
			return self[index]
		end
	end
	
	return nil
end

--- Gets the last value in this List that is accepted by the given function.
--
-- @param accept Optional. The function to accept values. Accepts the value and
--               returns a boolean, true if the value is accepted. If nil
--               the last value in the list will be returned.
-- @return The last accepted value, or if none was accepted, nil.
function List:get_last(accept)
	local value = nil
	
	for index = 1, self.counter - 1, 1 do
		if accept == nil or accept(self[index]) then
			value = self[index]
		end
	end
	
	return value
end

--- Returns the index of the given item.
--
-- @param item The item for which to get the index.
-- @param equals Optional. The equals function to use.
-- @return The index of the given item. -1 if this item is not in this list.
function List:index(item, equals)
	equals = equals or function(a, b)
		return a == b
	end
	
	for index = 1, self.counter - 1, 1 do
		if equals(self[index], item) then
			return index
		end
	end
	
	return -1
end

--- If the List contains functions, this invokes all items with the given
-- parameters.
--
-- @param ... The parameters to invoke the functions.
function List:invoke(...)
	for index = 1, self.counter - 1, 1 do
		self[index](...)
	end
end

--- Gets if this List is empty.
--
-- @return true if this List is empty.
function List:is_empty()
	return self.counter == 1
end

--- Returns a List with all items that match the given condition.
--
-- @param condition The condition, a function that accepts one parameter,
--                  the item, and returns a boolean.
-- @return The List of matching items.
function List:matching(condition)
	local found = List:new()
	
	for index = 1, self.counter - 1, 1 do
		local item = self[index]
		
		if condition(item) then
			found:add(item)
		end
	end
	
	return found
end

--- Removes the given values from the list.
--
-- @param ... The values to remove.
function List:remove(...)
	for index, value_to_remove in ipairs({...}) do
		self:remove_index(self:index(value_to_remove))
	end
end

--- Removes the given index from the list.
--
-- @param ... The index to remove.
function List:remove_index(...)
	local to_remove = {...}
	
	table.sort(to_remove)
	
	for index = #to_remove, 1, -1 do
		local index_to_remove = to_remove[index]
		
		if index_to_remove > 0 and index_to_remove < self.counter then
			for index_walk = index_to_remove, self.counter, 1 do
				self[index_walk] = self[index_walk + 1]
			end
			
			self.counter = self.counter - 1
		end
	end
end

--- Invokes the contained functions and returns the first value that is accepted
-- by the given function.
--
-- @param accept The function to accept values, takes the value and returns
--               a boolean, true if the value is accepted.
-- @param ... Optional. The parameters to invoke the functions with.
-- @return The first accepted return value, nil if none was accepted.
function List:return_first(accept, ...)
	for index = 1, self.counter - 1, 1 do
		local value = self[index](...)
		
		if accept(value) then
			return value
		end
	end
	
	return nil
end

--- Invokes the contained functions and returns the last value that is accepted
-- by the given function.
--
-- @param accept The function to accept values, takes the value and returns
--               a boolean, true if the value is accepted.
-- @param ... Optional. The parameters to invoke the functions with.
-- @return The last accepted return value, nil if none was accepted.
function List:return_last(accept, ...)
	local value = nil
	
	for index = 1, self.counter - 1, 1 do
		local returned_value = self[index](...)
		
		if accept(returned_value) then
			value = returned_value
		end
	end
	
	return value
end

--- Gets the size of the list.
--
-- @return The size of the list.
function List:size()
	return self.counter - 1
end

--- Sorts this List.
--
-- @param comparator Optional. The comparator to be used. Accepts two values
--                   and returns a boolean, true if the first is parameter is
--                   less than the second.
function List:sort(comparator)
	table.sort(self, comparator or tableutil.comparator)
end

--- Gets a sub list starting from the given index and the given number of items.
--
-- @param from The starting index.
-- @param count The count of items to get.
-- @return A List containing the items starting by the given index. The List
--         will be empty if the starting index is out of range, if there are not
--         as many items as specified with count, all items that there are will
--         be returned.
function List:sub_list(from, count)
	local sub = List:new()
	
	for index = math.max(from, 1), math.min(from + count - 1, self.counter - 1), 1 do
		sub:add(self[index])
	end
	
	return sub
end

--- Turns this list into a table, the return table will be a one indexed array,
-- and can freely be modified as it is not the table used by this instance.
-- However the items in the returned table are not copies.
--
-- @return This list as table.
function List:to_table()
	local table = {}
	
	self:foreach(function(item, index)
		table[index] = item
	end)
	
	return table
end

