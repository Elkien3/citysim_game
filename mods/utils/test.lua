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


--- A simple utility for testing values and running unit tests.
test = {}


--- Test if the given value matches the given expected value.
-- If the values do not match, an error with the given message (if any) and
-- an additional message containing both values will be shown.
--
-- The values will be compared with ==.
--
-- @param expected The expected value.
-- @param actual The actual value.
-- @param message Optional. The additional message to be printed.
function test.equals(expected, actual, message)
	if message ~= nil then
		message = message .. "\n"
	else
		message = ""
	end
	
	if expected == nil and actual ~= nil then
		error(message .. "Assert failed! Expected: <nil> but got <" .. tostring(actual) .. ">", 2)
	end
	
	if expected ~= nil and actual == nil then
		error(message .. "Assert failed! Expected: <" .. tostring(expected) .. "> but got <nil>", 2)
	end
	
	if expected ~= nil and actual ~= nil then
		if not tableutil.equals(expected, actual) then
			error(message .. "Assert failed! Expected <" .. tostring(expected) .. "> but got <" .. tostring(actual) .. ">", 2)
		end
	end
end

--- Runs the given method and prints a formatted information including the name.
--
-- @param name The name of the method that is being run.
-- @param test_method The method to run.
function test.run(name, test_method)
	io.write(string.rep(" ", 20 - string.len(name)))
	io.write(name)
	io.write(" ... ")
	
	local start = os.clock()
	
	local status, err = pcall(test_method)
	
	if status then
		local time = mathutil.round((os.clock() - start) * 1000, 3)
		print("Passed (" .. tostring(time) .. " ms)")
	else
		local indentation = string.rep(" ", 25)
		
		message = string.gsub(err, "\n", "\n" .. indentation)
		
		print("Failed: " .. message)
	end
end

--- Prints the given name as header.
--
-- @param name The name of the header.
function test.start(name)
	io.write("\n")
	io.write(string.rep("-", 20 - string.len(name)))
	io.write(name)
	io.write(string.rep("-", 60))
	print("")
end

