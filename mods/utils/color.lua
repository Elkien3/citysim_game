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


--- A simple container for a color and its hex string representation.
--
-- Even though it is not enforced, this container is assumed to be imutable.
Color = {
	--- The red component, a number between 0 and 255.
	red = 0,
	--- The green component, a number between 0 and 255.
	green = 0,
	--- The blue component, a number between 0 and 255.
	blue = 0,
	--- The hex representation, like FFFFFF for white.
	hex = "000000"
}


--- Creates a new instance of Color.
--
-- @param red The red component, a number between 0 and 255.
-- @param green The green component, a number between 0 and 255.
-- @param blue The blue component, a number between 0 and 255.
function Color:new(red, green, blue)
	local instance = {
		red = mathutil.clamp(red, 0, 255),
		green = mathutil.clamp(green, 0, 255),
		blue = mathutil.clamp(blue, 0, 255)
	}
	
	instance.hex = string.format("%02X%02X%02X", instance.red, instance.green, instance.blue)
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end

