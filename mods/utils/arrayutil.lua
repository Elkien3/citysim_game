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


--- Various utility functions for working with arrays. An array is sub-form of
-- a array, the array is simply indexed with numbers like this:
--
-- local array = { 1 = "a", 2 = "b", 3 = "c" }
-- local array = { "a", "b", "c" }
arrayutil = {}


--- Gets if the given array contains the given item.
--
-- @param array The array to search in.
-- @param item The item to search for, can either be an item or another array.
-- @param equals Optional. The function to determine if items equal each other,
--               defaults to tableutil.equals.
-- @param offset_step Optional. If the given item is an array, this determines
--                    how much of the array is skipped before it is tried to
--                    match.
-- @return true if the array contains the given item.
function arrayutil.contains(array, item, equals, offset_step)
	return arrayutil.index(array, item, equals, offset_step) >= 0
end

--- Creates a 2D array with the given bounds and sets it to the given default
-- value.
--
-- @param start_x The start of the first dimension, inclusive.
-- @param start_y The start of the second dimension, inclusive.
-- @param end_x The end of the first dimension, inclusive.
-- @param end_y The end of the second dimension, inclusive.
-- @param default_value The default value that will be set, it will be cloned
--                      for every entry.
-- @return The created 2D array.
function arrayutil.create2d(start_x, start_y, end_x, end_y, default_value)
	local array = {}
	
	for x = start_x, end_x, 1 do
		array[x] = {}
		
		for y = start_y, end_y, 1 do
			array[x][y] = tableutil.clone(default_value)
		end
	end
	
	return array
end

--- Creates a 3D array with the given bounds and sets it to the given default
-- value.
--
-- @param start_x The start of the first dimension, inclusive.
-- @param start_y The start of the second dimension, inclusive.
-- @param start_z The start of the third dimension, inclusive.
-- @param end_x The end of the first dimension, inclusive.
-- @param end_y The end of the second dimension, inclusive.
-- @param end_z The end of the third dimension, inclusive.
-- @param default_value The default value that will be set, it will be cloned
--                      for every entry.
-- @return The created 3D array.
function arrayutil.create3d(start_x, start_y, start_z, end_x, end_y, end_z, default_value)
	local array = {}
	
	for x = start_x, end_x, 1 do
		array[x] = {}
		
		for y = start_y, end_y, 1 do
			array[x][y] = {}
			
			for z = start_z, end_z, 1 do
				array[x][y][z] = tableutil.clone(default_value)
			end
		end
	end
	
	return array
end

--- Gets the index of the item in the given array.
--
-- @param array The array to search in.
-- @param item The item to search for, can either be an item or another array.
-- @param equals Optional. The function to determine if items equal each other,
--               defaults to tableutil.equals.
-- @param offset_step Optional. If the given item is an array, this determines
--                    how much of the array is skipped before it is tried to
--                    match.
-- @return The index of the given item or array, -1 if it was not found.
function arrayutil.index(array, item, equals, offset_step)
	equals = equals or tableutil.equals
	offset_step = offset_step or 1
	
	if #array == 0 then
		return -1
	end
	
	local item_is_array = type(item) == "table"
	
	if item_is_array then
		if #array < #item then
			return -1
		end
	end
	
	if item_is_array then
		for offset = 1, #array - 1, offset_step do	
			local match = true
			
			for index = 1, #item, 1 do
				local array_index = index + offset - 1
				
				if array_index > #array then
					array_index = array_index - #array
				end
				
				if not equals(array[array_index], item[index]) then
					match = false
					-- Ugly way to break a loop, I know.
					index = #item + 1
				end
			end
			
			if match then
				return offset
			end
		end
	else
		for index = 1, #array, 1 do
			if equals(array[index], item) then
				return index
			end
		end
	end
	
	return -1
end

--- Finds the next matching column.
--
-- @param array The 2D array to search.
-- @param start_index Optional. The index at which to start. Defaults to 1, or
--                    if the direction is reversed, the number of columns in
--                    the array.
-- @param matcher Optional. The function that is used to determine if the column
--                matches or not. Is expected to take one argument, the item,
--                and return a boolean. The column matches if any of its items
--                matches this condition. Defaults to not nil and not empty
--                string.
-- @param reverse Optional. If the array should be serched backwards. Defaults
--                to false.
-- @return The index of the matching column. -1 if none was found.
function arrayutil.next_matching_column(array, start_index, matcher, reverse)
	matcher = matcher or function(item)
		return item ~= nil and item ~= ""
	end
	
	local current_column = 0
	
	if reverse and start_index == nil then
		for row_index = 1, #array, 1 do
			local row = array[row_index]
			
			current_column = math.max(current_column, #row)
		end
	else
		current_column = start_index or 1
	end
	
	local had_column = true
	
	while had_column do
		had_column = false
		
		for row_index = 1, #array, 1 do
			local row = array[row_index]
			
			if current_column >= 1 and current_column <= #row then
				had_column = true
				
				if matcher(row[current_column]) then
					return current_column
				end
			end
		end
		
		if reverse then
			current_column = current_column - 1
		else
			current_column = current_column + 1
		end
	end
	
	return -1
end

--- Finds the next matching row.
--
-- @param array The 2D array to search.
-- @param start_index Optional. The index at which to start. Defaults to 1, or
--                    if the direction is reversed, the number of rows in
--                    the array.
-- @param matcher Optional. The function that is used to determine if the row
--                matches or not. Is expected to take one argument, the item,
--                and return a boolean. The row matches if any of its items
--                matches this condition. Defaults to not nil and not empty
--                string.
-- @param reverse Optional. If the array should be serched backwards. Defaults
--                to false.
-- @return The index of the matching row. -1 if none was found.
function arrayutil.next_matching_row(array, start_index, matcher, reverse)
	matcher = matcher or function(item)
		return item ~= nil and item ~= ""
	end
	
	local to = #array
	local step = 1
	
	if reverse then
		start_index = start_index or #array
		to = 1
		step = -1
	else
		start_index = start_index or 1
	end
	
	for row_index = start_index, to, step do
		local row = array[row_index]
		
		for column_index = 1, #row, 1 do
			if matcher(row[column_index]) then
				return row_index
			end
		end
	end
	
	return -1
end

--- Finds the previous matching column.
--
-- @param array The 2D array to search.
-- @param start_index Optional. The index at which to start. Defaults to
--                    the number columns in the array.
-- @param matcher Optional. The function that is used to determine if the column
--                matches or not. Is expected to take one argument, the item,
--                and return a boolean. The column matches if any of its items
--                matches this condition. Defaults to not nil and not empty
--                string.
-- @return The index of the matching column. -1 if none was found.
function arrayutil.previous_matching_column(array, start_index, matcher)
	return arrayutil.next_matching_column(array, start_index, matcher, true)
end

--- Finds the previous matching row.
--
-- @param array The 2D array to search.
-- @param start_index Optional. The index at which to start. Defaults to
--                    the number rows in the array.
-- @param matcher Optional. The function that is used to determine if the row
--                matches or not. Is expected to take one argument, the item,
--                and return a boolean. The row matches if any of its items
--                matches this condition. Defaults to not nil and not empty
--                string.
-- @return The index of the matching row. -1 if none was found.
function arrayutil.previous_matching_row(array, start_index, matcher)
	return arrayutil.next_matching_row(array, start_index, matcher, true)
end

--- Removes empty rows and columns at the beginning and the end of the given
-- array.
--
-- @param array The array.
-- @param is_empty Optional. The function used for determining if the item is
--                 empty. By default nil and an empty string is considered
--                 empty. Expected is a function that takes one item and returns
--                 a boolean.
function arrayutil.reduce2d(array, is_empty)
	local first_row = arrayutil.next_matching_row(array, nil, is_empty)
	local last_row = arrayutil.previous_matching_row(array, nil, is_empty)
	
	local first_column = arrayutil.next_matching_column(array, nil, is_empty)
	local last_column = arrayutil.previous_matching_column(array, nil, is_empty)
	
	if last_row == -1 then
		last_row = first_row
	end
	
	if last_column == -1 then
		last_column = first_column
	end
	
	local reduced = {}
	
	if first_row ~= -1 and first_column ~= -1 then
		for row_index = first_row, last_row, 1 do
			local row = array[row_index]
			local reduced_row = {}
		
			for column_index = first_column, last_column, 1 do
				reduced_row[column_index - first_column + 1] = row[column_index]
			end
		
			reduced[row_index - first_row + 1] = reduced_row
		end
	end
	
	return reduced
end

--- Reindexes the given 2D array, swapping the two dimensions.
--
-- @param data The array to reindex.
-- @param new_x The new startpoint for the first dimension.
-- @param new_y The new startpoint for the second dimension.
-- @return The reindexed array.
function arrayutil.swapped_reindex2d(data, new_x, new_y)
	local reindexed_data = {}
	
	for old_x = 1, constants.block_size, 1 do
		local index_x = new_x + old_x - 1
		reindexed_data[index_x] = {}
		
		for old_y = 1, constants.block_size, 1 do
			local index_y = new_y + old_y - 1
				
			reindexed_data[index_x][index_y] = data[old_y][old_x]
		end
	end
	
	return reindexed_data
end

--- Reindexes the given 3d array, swapping the two dimensions.
--
-- @param data The array to reindex.
-- @param new_x The new startpoint for the first dimension.
-- @param new_y The new startpoint for the second dimension.
-- @param new_z The new startpoint for the third dimension.
-- @return The reindexed array.
function arrayutil.swapped_reindex3d(data, new_x, new_y, new_z)
	local reindexed_data = {}
	
	for old_x = 1, constants.block_size, 1 do
		local index_x = new_x + old_x - 1
		reindexed_data[index_x] = {}
	
		for old_z = 1, constants.block_size, 1 do
			local index_z = new_z + old_z - 1
			reindexed_data[index_x][index_z] = {}
		
			for old_y = 1, constants.block_size, 1 do
				local index_y = new_y + old_y - 1
			
				reindexed_data[index_x][index_z][index_y] = data[old_z][old_y][old_x]
			end
		end
	end
	
	return reindexed_data
end

