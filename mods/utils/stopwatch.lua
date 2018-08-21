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


--- Allows to easily time blocks of code. The result will be logged.
stopwatch = {
	active_watches = {}
}


--- Start a watch with the given name.
--
-- @param watch_name The name of the watch to start.
function stopwatch.start(watch_name)
	stopwatch.active_watches[watch_name] = os.clock()
end


--- Stops the watch with the given name, logging the duration.
--
-- It will be logged as info in the format "watch_name: duration ms" or
-- if the message is provided "message: duration ms"
-- @param watch_name The name of the watch to stop.
-- @param message Optional. The message to use for the log instead of the name.
-- @param decimal_places Optional. To how many decimal places the time should
--                       be rounded. Defaults to 3.
function stopwatch.stop(watch_name, message, decimal_places)
	decimal_places = decimal_places or 3
	
	local duration = stopwatch.stop_only(watch_name)
	duration = mathutil.round(duration, decimal_places)

	log.info(message or watch_name, ": ", duration, " ms")
end

--- Stops the watch with the given name and returns the duration for which
-- the watch has been running.
--
-- @param watch_name The name of the watch to stop.
-- @return The duration of the watch. -1 if it never was started.
function stopwatch.stop_only(watch_name)
	local start = stopwatch.active_watches[watch_name]
	
	stopwatch.active_watches[watch_name] = nil
	
	if start ~= nil then
		local duration = os.clock() - start
		duration = duration * 1000
		
		return duration
	else
		return -1
	end
end

