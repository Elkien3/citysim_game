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


--- Various mathematical functions for interpolating values.
interpolate = {}


--- Performs a cosine interpolation with the given offset between the given
-- min and max values.
--
-- @param offset The offset to get, should be between 0 and 1.
-- @param min Optional. The minimum value of the range, defaults to 0.
-- @param max Optional. The maximum value of the range, defaults to 1.
-- @return The interpolated value at the given offset.
function interpolate.cosine(offset, min, max)
	local value = (1 - math.cos(offset * math.pi)) / 2
	
	if min ~= nil and max ~= nil then
		return min * (1 - value) + max * value
	else
		return value
	end
end

--- Performs a linear interpolation with the given offset between the given
-- min and max values.
--
-- @param offset The offset to get, should be between 0 and 1.
-- @param min Optional. The minimum value of the range, defaults to 0.
-- @param max Optional. The maximum value of the range, defaults to 1.
-- @return The interpolated value at the given offset.
function interpolate.linear(offset, min, max)
	return min * (1 - offset) + max * offset
end

