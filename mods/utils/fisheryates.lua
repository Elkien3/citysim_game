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


--- An implementation of the Fisher-Yates algorithm, which allows to access
-- an array in a random or pseudo-random order.
fisheryates = {}


--- Runs the Fisher-Yates algorithm on the given data.
--
-- The given action method is invoked on each item, which means that the action
-- method gets items in random order.
--
-- @param data The array on which to operate.
-- @param min The minimum index of the array (inclusive).
-- @param max The maximum index of the array (inclusive).
-- @param random The method that returns random numbers, assumed to accept two
--               parameters, a minimum and maximum value. Can also be a table
--               with an instance method like the one descriped above.
-- @param action The action to perform on each item. Assumed to accept two
--               parameters, the item and the current index.
function fisheryates.run(data, min, max, random, action)
	local random_is_object = type(random) == "userdata"
	
	for index = min, max, 1 do
		local swap_index = nil
		
		if random_is_object then
			swap_index = random:next(0, 32767)
		else
			swap_index = random(0, 32767)
		end
		
		swap_index = transform.linear(swap_index, 0, 32767, index, max)
		swap_index = mathutil.round(swap_index)
		
		local swap_value = data[swap_index]
		
		data[swap_index] = data[index]
		data[index] = swap_value
		
		action(data[index], index)
	end
end

