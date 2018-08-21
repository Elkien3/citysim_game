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


--- Encapsulates the settings API of minetest and extends it with further
-- functions.
settings = {}


--- Gets a value from the configuration as is.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default_value to return if the value is
--                      not set in the configuration. Can be nil.
-- @param cast_function Optional. The function to apply to the value that is
--                      read, for example to convert it into a different type.
--                      If this function returns nil, the default value IS
--                      returned. Can be nil.
-- @return The value from the configuration with the given name. If the read
--         value is nil, the default value is returned or nil.
function settings.get(name, default_value, cast_function)
	local value = minetest.setting_get(name)
	
	if value ~= nil and cast_function ~= nil then
		value = cast_function(value)
	end
	
	if value ~= nil then
		return value
	else
		return default_value
	end
end

--- Gets a boolean from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The boolean with the given name, or the default value if it is nil,
--         or nil.
function settings.get_bool(name, default_value)
	local value = minetest.setting_getbool(name)
	
	if value ~= nil then
		return value
	else
		return default_value
	end
end

--- Gets a list from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is
--                      nil. Can be nil.
-- @return The list with the given name, or the default value if it is nil,
--        or nil.
function settings.get_list(name, default_value)
	local value = settings.get(name, nil, tostring)
	
	if value ~= nil then
		return stringutil.split(value, ",")
	elseif type(default_value) == "string" then
		return stringutil.split(default_value, ",")
	else
		return default_value
	end
end

--- Gets a number from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The number with the given name, or the default value if it is nil,
--         or nil.
function settings.get_number(name, default_value)
	return settings.get(name, default_value, tonumber)
end

--- Gets a pos (with x and y values) from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The pos with the given name, or the default value if it is nil,
--         or nil.
function settings.get_pos2d(name, default_value)
	local value = minetest.setting_get(name)
	
	if value ~= nil then
		local splitted_value = stringutil.split(value, ",")
		
		if splitted_value:size() == 2 then
			local x = tonumber(splitted_value:get(1))
			local y = tonumber(splitted_value:get(2))
			
			if x ~= nil and y ~= nil then
				return {
					x = x,
					y = y
				}
			end
		end
	end
	
	return default_value
end

--- Gets a pos with (x, y and z values) from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The pos with the given name, or the default value if it is nil,
--         or nil.
function settings.get_pos3d(name, default_value)
	local value = minetest.setting_get_pos(name)
	
	if value ~= nil then
		return value
	else
		return default_value
	end
end

--- Gets a string from the configuration.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The string with the given name, or the default value if it is nil,
--         or nil.
function settings.get_string(name, default_value)
	return settings.get(name, default_value, tostring)
end

--- Gets a table with the given keys form the configuration.
--
-- @param name The name of the value to get.
-- @param default_value The default value to return if the value is nil, can be
--                      nil.
-- @param ... The name of the keys.
-- @return The table with the given name and the given keys, or the default
--         value it is nil.
function settings.get_table(name, default_value, ...)
	local value = settings.get_list(name, nil)
	
	if value ~= nil then
		local table = {}
		
		if ... ~= nil then
			for index, key in ipairs({...}) do
				table[key] = value:get(index)
			end
		end
		
		if ... == nil or  #{...} < value:size() then
			for index = #{...} + 1, value:size(), 1 do
				table[index] = value:get(index)
			end
		end
		
		return table
	else
		return default_value
	end
end

--- Saves all settings to configuration file.
function settings.save()
	minetest.setting_save()
end

--- Set a value with the given name into the configuration.
--
-- @param name The name of the value to set. Is not allowed to contain '="#{}'.
-- @param value The value.
function settings.set(name, value)
	minetest.setting_set(name, value)
end

--- Gets a pos from the configuration, this is an alias for get_pos3d.
--
-- @param name The name of the value to get.
-- @param default_value Optional. The default value to return if the value is nil.
--                      Can be nil.
-- @return The pos with the given name, or the default value if it is nil,
--         or nil.
settings.get_pos = settings.get_pos3d

