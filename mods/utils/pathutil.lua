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


--- Various utility functions for working with paths.
pathutil = {
	
	--- The path delimiter used.
	delimiter = "/"
}

--- Concats all given value into a valid path.
--
-- @param ... The items to concatenate. Assumed to be strings.
-- @return A pthat delimited by the current path delimiter.
function pathutil.concat(...)
	if ... == nil then
		return ""
	end
	
	local path = ""
	
	for idx, value in ipairs({...}) do
		if value ~= nil and value ~= "" then
			if path ~= "" and stringutil.startswith(value, pathutil.delimiter) then
				value = string.sub(value, string.len(pathutil.delimiter) + 1)
			end
			
			if stringutil.endswith(value, pathutil.delimiter) then
				value = string.sub(value, 1, -string.len(pathutil.delimiter))
			end
			
			if not stringutil.endswith(path, pathutil.delimiter) and path ~= "" then
					path = path .. pathutil.delimiter
			end
			
			path = path .. tostring(value)
		end
	end
	
	return path
end

