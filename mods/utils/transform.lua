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


--- Various mathematical functions for transforming values.
transform = {}


--- Performs a linear transform on the given value to transform the value
-- from the range -10/10 to 0/1.
--
-- @param value The value to transform.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.big_linear(value, new_min, new_max)
	return transform.linear(value, -10, 10, new_min, new_max)
end

--- Performs the given transformation on the given value with the peak in center
-- of the min and max values.
--
-- @param value The value to transform.
-- @param transformation The transformation function, assumed to accept five
--                       values.
-- @param min Optional. The original minimum value, defaults to -1.
-- @param max Optional. The original maximum value, default to 1.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.centered(value, transformation, min, max, new_min, new_max)
	min = min or -1
	max = max or 1
	
	local center = (min + max) / 2
	
	if value < center then
		return transformation(value, min, center, new_min, new_max)
	else
		return transformation(value, max, center, new_min, new_max)
	end
end

--- Performs a cosine transformation on the given value with the peak in center
-- of the min and max values.
--
-- @param value The value to transform.
-- @param min Optional. The original minimum value, defaults to -1.
-- @param max Optional. The original maximum value, default to 1.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.centered_cosine(value, min, max, new_min, new_max)
	return transform.centered(value, transform.cosine, min, max, new_min, new_max)
end

--- Performs a linear transformation on the given value with the peak in center
-- of the min and max values.
--
-- @param value The value to transform.
-- @param min Optional. The original minimum value, defaults to -1.
-- @param max Optional. The original maximum value, default to 1.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
function transform.centered_linear(value, min, max, new_min, new_max)
	return transform.centered(value, transform.linear, min, max, new_min, new_max)
end

--- Performs a cosine transform on the given value to transform the value
-- from one range to another.
--
-- @param value The value to transform.
-- @param min Optional. The original minimum value of the range, defaults to -1.
-- @param max Optional. The original maximum value of the range, defaults to 1.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.cosine(value, min, max, new_min, new_max)
	min = min or -1
	max = max or 1
	
	if new_min == nil or new_max == nil then
		return interpolate.cosine((value - min) / (max - min))
	else
		return interpolate.cosine((value - min) / (max - min)) * (new_max - new_min) + new_min
	end
end

--- Performs a linear transform on the given value to transform the value
-- from one range to another.
--
-- @param value The value to transform.
-- @param min Optional. The original minimum value of the range, defaults to -1.
-- @param max Optional. The original maximum value of the range, defaults to 1.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.linear(value, min, max, new_min, new_max)
	min = min or -1
	max = max or 1
	
	if new_min == nil or new_max == nil then
		return (value - min) / (max - min)
	else
		return (value - min) / (max - min) * (new_max - new_min) + new_min
	end
end

--- Performs a linear transform on the given value to transform the value
-- from the range -1/1 to 0/1.
--
-- @param value The value to transform.
-- @param new_min Optional. The minimum value for the new range, defaults to 0.
-- @param new_max Optional. The maximum value for the new range, defaults to 1.
-- @return The transformed value.
function transform.small_linear(value, new_min, new_max)
	return transform.linear(value, -1, 1, new_min, new_max)
end

