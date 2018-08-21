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


--- Various utility functions for working with tables.
tableutil = {}


--- Performs a deep/recursive clone on the given table.
--
-- @param table The table to deep clone.
-- @return The clone of the table.
function tableutil.clone(table)
	if table == nil then
		return nil
	end
	
	if type(table) ~= "table" then
		local clone = table
		return clone
	end
	
	local clone = {}
	
	for key, value in next, table, nil do
		if value ~= table then
			clone[tableutil.clone(key)] = tableutil.clone(value)
		else
			clone[tableutil.clone(key)] = clone
		end
	end
	
	setmetatable(clone, tableutil.clone(getmetatable(table)))
	
	return clone
end

--- A comparator function that can be used for sorting a table with different
-- value types. It sorts numbers first, after that strings, tables and nil.
--
-- @param a The first value.
-- @param b The second value.
-- @return true if the first value is less than (should come before) the second.
function tableutil.comparator(a, b)
	if a == b then
		return false
	end
	
	if a ~= nil and b == nil then
		return false
	elseif b ~= nil and a == nil then
		return true
	end
	
	local type_a = type(a)
	local type_b = type(b)
	
	if type_a == "number" and type_b == "number" then
		return a < b
	elseif type_a == "string" and type_b == "string" then
		return a < b
	elseif type_a == "number" and type_b == "string" then
		return true
	elseif type_a == "string" and type_b == "number" then
		return false
	elseif type_a ~= "table" and type_b == "table" then
		return true
	else
		-- We can't sort objects.
		return false
	end
end

--- Tests the two given tables for equality.
--
-- @param a The first table.
-- @param b The second table.
-- @return true if the tables are equal.
function tableutil.equals(a, b)
	if a == b then
		return true
	end
	
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	
	if #a ~= #b then
		return false
	end
	
	local keys = tableutil.keys(a, b):to_table()
	
	for index, key in pairs(keys) do
		local valuea = a[key]
		local valueb = b[key]
		
		if type(valuea) == "table" then
			if not tableutil.equals(valuea, valueb) then
				return false
			end
		else
			if valuea ~= valueb then
				return false
			end
		end
	end
	
	return true
end

--- Returns a (unique) list with all keys of all tables.
--
-- @param ... The list of tables.
-- @return A list with all keys.
function tableutil.keys(...)
	if ... == nil then
		return List:new()
	end
	
	local keys = List:new()
	
	for index, table in ipairs({...}) do
		for key, value in pairs(table) do
			if not keys:contains(key) then
				keys:add(key)
			end
		end
	end
	
	return keys
end

--- Merges the given tables into one instance. Note that no cloning is performed
-- so fields may refer to the same instances.
--
-- @param ... The tables to merge.
-- @return The merged table.
function tableutil.merge(...)
	if ... == nil then
		return nil
	end
	
	local merged = {}
	
	for index, table in ipairs({...}) do
		for key, value in next, table, nil do
			merged[key] = value
		end
	end
	
	return merged
end


--- Returns the string representation of the given table.
--
-- @param table The table.
-- @param one_line Optional. If the table should be printed on only one line.
--                 Defaults to false.
-- @param table_ids Optional. If the table IDs should be printed.
--                  Defaults to true.
-- @param indent Optional. The number of spaces of indentation.
-- @return The string representation of the given table.
function tableutil.to_string(table, one_line, table_ids, indent)
	if table == nil then
		return "nil"
	end
	
	indent = indent or 0
	
	if type(table) == "table" then
		local str = ""
		
		if table_ids == nil or table_ids then
			str = str .. tostring(table) .. " (" .. tostring(#table) .. ")"
		end
		
		str = str .. " {"
		
		if one_line then
			str = str .. " "
		else
			str = str .. "\n"
		end
		
		local indentation = string.rep(" ", indent + 4)
		
		local keys = tableutil.keys(table)
		keys:sort()
		
		keys:foreach(function(key, index)
			if not one_line then
				str = str .. indentation
			end
			
			str = str .. tostring(key) .. " = "
			str = str .. tableutil.to_string(table[key], one_line, table_ids, indent + 4) .. ","
			
			if one_line then
				str = str .. " "
			else
				str = str .. "\n"
			end
		end)
		
		str = string.sub(str, 0, string.len(str) - 2)
		
		if one_line then
			str = str .. " "
		else
			str = str .. "\n" .. string.rep(" ", indent)
		end
		
		str = str .. "}"
		
		return str
	elseif type(table) == "string" then
		return "\"" .. tostring(table) .. "\""
	else
		return tostring(table)
	end
end

