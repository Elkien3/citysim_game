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


--- Random is a static utility that provides fast and easy access to
-- random numbers.
random = {
	--- The internal maximum value.
	max = 2147483646,
	
	--- The internal minimum value.
	min = 0,
	
	--- The provider for random numbers.
	random_provider = nil
}


--- Initializes random. Should not be called from the client.
function random.init()
	if PcgRandom ~= nil then
		random.random_provider = PcgRandom(os.time())
	else
		math.randomseed(os.time())
		
		random.random_provider = {
			next = function(self, lower_bound, upper_bound)
				return math.abs(math.random(lower_bound, upper_bound))
			end
		}
	end
end

--- Returns true or false based on the given chance.
--
-- @param chance Optional. The "one in chance" chance to get true, defaults
--               to 2 (ans in "one in two").
-- @return true or false based in the given chance.
function random.next_bool(chance)
	chance = chance or 2
	
	if chance <= 0 then
		return false
	elseif chance == 1 then
		return true
	end
	
	return random.next_int(0, chance) == chance - 1
end

--- Returns a float between the given bounds.
--
-- @param lower_bound Optional. The lower bound (inclusive), defaults to 0.
-- @param upper_bound Optional. The upper bound (inclusive), defaults to 1.
-- @param decimal_places Optional. To how many decimal places the resulting
--                       float should be rounded.
-- @return a float between the given bounds.
function random.next_float(lower_bound, upper_bound, decimal_places)
	lower_bound = lower_bound or 0
	upper_bound = upper_bound or 1.0
	
	local value = random.random_provider:next(random.min, random.max)
	value = (value - random.min) / (random.max - random.min)
	value = value * (upper_bound - lower_bound) + lower_bound
	
	if decimal_places then
		value = mathutil.round(value, decimal_places)
	end
	
	return value
end

--- Returns an int between the given bounds.
--
-- @param lower_bound Optional. The lower bound (inclusive), defaults to
--                    random.min.
-- @param upper_bound Optional. The upper bound (inclusive), defaults to
--                    random.max.
-- @return a integer between the given bounds.
function random.next_int(lower_bound, upper_bound)
	lower_bound = lower_bound or random.min
	upper_bound = upper_bound or random.max
	
	return random.random_provider:next(lower_bound, upper_bound)
end


-- Initialize the random object.
random.init()

