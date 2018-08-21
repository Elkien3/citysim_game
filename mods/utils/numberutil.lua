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


--- Various functions for working with numbers.
numberutil = {}


--- Formats the given number into a nice, readable string.
--
-- @param number The number to format.
-- @param decimal_places Optional. How many decimal places to show. The number
--                       will be rounded to this amount of decimal places,
--                       if omitted, as many as there are are printed.
-- @param decimal_separator Optional. The decimal separator to use, defaults
--                          to a dot.
-- @param thousand_separator Optional. The thousand separator to use, defaults
--                           to a comma.
-- @return The formatted number.
function numberutil.format(number, decimal_places, decimal_separator, thousand_separator)
	decimal_separator = decimal_separator or "."
	thousand_separator = thousand_separator or ","
	
	if decimal_places then
		number = mathutil.round(number, decimal_places)
	end
	
	local number_string = tostring(number)
	
	local start_index, end_index, minus, integer, fraction = string.find(number_string, "(-?)(%d+)([.]?%d*)")
	
	local formatted = ""

	if #integer > 3 then
		for index = #integer, 3, -3 do
			formatted = thousand_separator .. string.sub(integer, index - 2, index) .. formatted
		end
		
		local rest = math.fmod(#integer, 3)
		if rest > 0 then
			formatted = string.sub(integer, 1, rest) .. formatted
		end
	else
		formatted = integer .. formatted
	end
	
	if minus ~= nil and minus ~= "" then
		formatted = minus .. formatted
	end
	
	if decimal_places == nil or decimal_places > 0 then
		if fraction ~= nil and fraction ~= "" then
			fraction = string.sub(fraction, 2)
			
			if decimal_places and #fraction < decimal_places then
				fraction = fraction .. string.rep("0", decimal_places - #fraction)
			end
			
			formatted = formatted .. decimal_separator .. fraction
		elseif decimal_places ~= nil then
			formatted = formatted .. decimal_separator .. string.rep("0", decimal_places)
		end
	end
	
	return formatted
end

