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


--- Various utility functions for working with strings.
stringutil = {}


--- Concats all the given items by invoking tostring on them into one string.
--
-- @param ... The items to concat.
-- @return The concatenated items as string.
function stringutil.concat(...)
	if ... == nil then
		return ""
	end
	
	local string = ""
	
	for idx, value in ipairs({...}) do
		string = string .. tostring(value)
	end
	
	return string
end

--- Tests if the given text ends with the given value.
--
-- @param text The text to check if it ends with the given value.
-- @param value The value that text should end with.
-- @return true if the given text ends with the value.
function stringutil.endswith(text, value)
	if text == nil or value == nil then
		return false
	end
	
	if value == "" then
		return true
	end
	
	return string.sub(text, -string.len(value)) == value
end

--- Creates a simple hash in the range of mathutil.SIGNED_32BIT_MIN and
-- mathutil.SIGNED_32BIT_MAX (which is roughly -2 billion to 2 billion).
-- Note that this is not the best string hash function there could be, but is
-- more than sufficient if all you want is to test a string if it is different
-- or if you want to create a number from a string of unknown length.
--
-- @param value The string value to hash.
-- @return The hash. Always 0 if the given string is nil or empty.
function stringutil.hash(value)
	-- Early bailout.
	if value == nil or #value == 0 then
		return 0
	end
	
	local hash = 0
	
	for index = 1, #value, 1 do
		hash = hash * 31 + string.byte(string.sub(value, index, index))
		
		while hash > mathutil.SIGNED_32BIT_MAX do
			hash = hash - mathutil.SIGNED_32BIT_MAX
		end
	end
	
	return hash
end

--- Splits the given text using the given split value. Returns the splitted text
-- as List. If the string is empty or nil, the returned list will not contain
-- any entries. If the string only contains a value without a separator,
-- the list will contain one value, if it contains only the separator,
-- two empty values.
--
-- @param text The text to split.
-- @param split The split value.
-- @param trim_values Optional. If the values should be trimmed, defaults to
--                    true.
-- @return The list of splitted values.
function stringutil.split(text, split, trim_values)
	if trim_values == nil then
		trim_values = true
	end
	
	local splitted = List:new()
	
	if string ~= nil and #text > 0 then
		local previous_starts = 0
		local previous_ends = 0
		local starts, ends = string.find(text, split, 0, true)
		
		while ends ~= nil do
			local value = string.sub(text, previous_ends + 1, starts - 1)
			
			if trim_values then
				value = stringutil.trim(value)
			end
			
			splitted:add(value)
			
			previous_starts = starts
			previous_ends = ends
			starts, ends = string.find(text, split, ends + 1, true)
		end
		
		if previous_ends > 0 or splitted:size() == 0 then
			local value = string.sub(text, previous_ends + 1)
			
			if trim_values then
				value = stringutil.trim(value)
			end
			
			splitted:add(value)
		end
	end
	
	return splitted
end

--- Tests if the given text starts with the given value.
--
-- @param text The text to check if it starts with the given value.
-- @param value The value that text should start with.
-- @return true if the given text starts with the value.
function stringutil.startswith(text, value)
	if text == nil or value == nil then
		return false
	end
	
	if value == "" then
		return true
	end
	
	return string.sub(text, 1, string.len(value)) == value
end

--- Trims the given text from any leading and trailing whitespace.
--
-- @param text The text to trim.
-- @return The trimmed text.
function stringutil.trim(text)
	if text ~= nil and #text > 0 then
		local trimmed = string.gsub(text, "^%s+", "")
		trimmed = string.gsub(trimmed, "%s+$", "")
		
		return trimmed
	end
	
	return text
end

