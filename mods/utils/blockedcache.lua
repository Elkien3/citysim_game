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


--- A simple cache for caching values based on x and z coordinates.
--
-- Also manages the amount of cached entries and can automatically compact
-- the cache to remove the oldest values.
BlockedCache = {}


--- Creates a new instance of BlockedCache.
--
-- @param max_entries Optional. The maximum entries for the cache which will be
--                    preserved if the cache is compacted, defaults to 12.
-- @param auto_compact Optional. If the cache performs automatic compaction if
--                     the maximum numbers of entries is reached, defaults
--                     to true.
-- @return A new instance of BlockedCache.
function BlockedCache:new(max_entries, auto_compact)
	if auto_compact == nil then
		auto_compact = true
	end
	
	local instance = {
		auto_compact = auto_compact,
		cache = {},
		index = {},
		index_end = 0,
		index_start = 0,
		max_entries = max_entries or 12
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Clears the complete cache.
function BlockedCache:clear()
	self.cache = {}
	self.index = {}
	self.index_end = 0
	self.index_start = 0
end

--- Compacts the cache, meaning it removes the oldest entries up to the maximum
-- number of entries.
--
-- @param max_entries Optional. The maximum number of cache entries to preserve.
function BlockedCache:compact(max_entries)
	if max_entries == nil then
		max_entries = self.max_entries
	end
	
	local new_index = 0
	local start_index = self.index_end - max_entries
	start_index = math.max(start_index, self.index_start)
	
	for old_index = self.index_start, self.index_end - 1, 1 do
		local entry = self.index[old_index]
		self.index[old_index] = nil
		
		if old_index >= start_index then
			self.index[new_index] = entry
			new_index = new_index + 1
		else
			self.cache[entry.x][entry.z] = nil
		end
		
		self.index_end = new_index
	end
end

--- Gets the value associated with the given x and z coordinates.
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @return The value associated with the given x and z coordinates. Returns nil
--         if there is no entry.
function BlockedCache:get(x, z)
	if self:is_cached(x, z) then
		return self.cache[x][z]
	end
	
	return nil
end

--- Gets if there is a cache entry associated with the given x and z
-- coordinates.
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @return true if there is an entry for the given coordinates.
function BlockedCache:is_cached(x, z)
	return self.cache[x] ~= nil and self.cache[x][z] ~= nil
end

--- Puts the value for the given x and z coordinates
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @param value The value to put.
function BlockedCache:put(x, z, value)
	if self.cache[x] == nil then
		self.cache[x] = {}
	end
	
	self.cache[x][z] = value
	self.index[self.index_end] = { x = x, z = z }
	self.index_end = self.index_end + 1
	
	if self.auto_compact and (self.index_end - self.index_start) > self.max_entries then
		self:compact()
	end
end

--- Gets a string representation of this cache.
--
-- @return The string representation.
function BlockedCache:to_string()
	local value = ""
	
	for idx = self.index_start, self.index_end - 1, 1 do
		value = value .. tostring(idx) .. ": "
		
		local entry = self.index[idx]
		value = value .. tostring(entry.x) .. ", " .. tostring(entry.z)
		
		value = value .. ": " .. tostring(self.cache[entry.x][entry.z])
		
		value = value .. "\n"
	end
	
	return value
end

