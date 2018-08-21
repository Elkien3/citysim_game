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


--- The NoiseManager manages seeds and creates PRNG of various kinds, always
-- with a new, unique seed. The seed is incremented with each creation, so
-- it is guaranteed that the results are reproducable.
NoiseManager = {}


--- Creates a new instance of NoiseManager.
--
-- @param start_seed Optional. The initial seed value, defaults to 0.
-- @param size_x Optional. The map size in the x direction, defaults to
--               the mapchunk size (see blockutil.MAPCHUNK_SIZE).
-- @param size_y Optional. The map size in the y direction, defaults to size_x.
-- @param size_z Optional. The map size in the z direction, defaults to size_z.
-- @return A new instance of NoiseManager.
function NoiseManager:new(start_seed, size_x, size_y, size_z)
	local instance = {
		map_size = {
			x = size_x or blockutil.MAPCHUNK_SIZE,
			y = size_y or size_x or blockutil.MAPCHUNK_SIZE,
			z = size_z or size_x or blockutil.MAPCHUNK_SIZE
		},
		next_seed = start_seed or 0
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Creates a Perlin object with the given values.
--
-- @param octaves The count of octaves.
-- @param persistence The persistence values.
-- @param scale The scale.
-- @return The new Perlin object.
function NoiseManager:get_noise(octaves, persistence, scale)
	self.next_seed = self.next_seed + 1
	
	return minetest.get_perlin(self.next_seed, octaves, persistence, scale)
end

-- Creates a PerlinMap object with the given values suitable for 2D noise.
--
-- @param octaves The count of octaves.
-- @param persistence The persistence value.
-- @param scale The scale.
-- @param spreadx The spread of the x axis.
-- @param spready Optional. The spread of the y axis, defaults to spreadx.
-- @param flags Optional. Additional flags for the noise.
-- return The new PerlinMap object.
function NoiseManager:get_map2d(octaves, persistence, scale, spreadx, spready, flags)
	return self:get_map3d(octaves, persistence, scale, spreadx, spready, 1, flags)
end

-- Creates a PerlinMap object with the given values suitable for 3D noise.
--
-- @param octaves The count of octaves.
-- @param persistence The persistence value.
-- @param scale The scale.
-- @param spreadx The spread of the x axis.
-- @param spready Optional. The spread of the y axis, defaults to spreadx.
-- @param spreadz Optional. The spread of the z axis, defaults to spreadx.
-- @param flags Optional. Additional flags for the noise.
-- return The new PerlinMap object.
function NoiseManager:get_map3d(octaves, persistence, scale, spreadx, spready, spreadz, flags)
	self.next_seed = self.next_seed + 1
	
	local parameters = {
		offset = 0,
		scale = scale,
		spread = {
			x = spreadx,
			y = spready or spreadx,
			z = spreadz or spreadx
		},
		seed = self.next_seed,
		octaves = octaves,
		persist = persistence,
		flags = flags
	}
	
	return minetest.get_perlin_map(parameters, self.map_size)
end

--- Gets the next seed that will be used. Does not increment the counter.
--
-- @return The next seed that will be used.
function NoiseManager:get_next_seed()
	return self.next_seed
end

--- Creates a PcgRandom object.
--
-- @return The new PcgRandom object.
function NoiseManager:get_pcgrandom()
	self.next_seed = self.next_seed + 1
	
	return PcgRandom(self.next_seed)
end

--- Creates a PseudoRandom object.
--
-- @return The new PseudoRandom object.
function NoiseManager:get_random()
	self.next_seed = self.next_seed + 1
	
	return PseudoRandom:new(self.next_seed)
end

