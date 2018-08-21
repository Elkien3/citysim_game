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


--- A simple utility for logging purposes.
--
-- This utility uses the minetest.log() method. If the minetest object is not
-- available, it will fallback to printing the messages to stdout.
log = {
	--- Whether all messages should be printed instead of being handed
	-- to Minetest (if available).
	print_all = false
}


--- Logs an action.
--
-- @param ... The message to log.
function log.action(...)
	log.log("action", ...)
end

--- Logs an error.
--
-- @param ... The message to log.
function log.error(...)
	log.log("error", ...)
end

--- Logs an info.
--
-- @param ... The message to log.
function log.info(...)
	log.log("info", ...)
end

--- Logs a message with the given level.
--
-- @param level The log level, should be action, error, info or verbose to
--              stay compatible with minetest.
-- @param ... The message to log.
function log.log(level, ...)
	if not log.print_all and minetest ~= nil then
		minetest.log(level, stringutil.concat(...))
	else
		print(stringutil.concat("[", string.upper(level), "] ", ...))
	end
end

--- Allows to activate or deactivate that all messages are printed.
--
-- @param print_all true if all messages should be printed, false if messages
--                  should be handed to Minetest (if available).
function log.set_print_all(print_all)
	log.print_all = print_all
end

--- Logs a message.
--
-- @param ... The message to log.
function log.verbose(...)
	log.log("verbose", ...)
end

