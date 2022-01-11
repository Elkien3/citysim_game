--[[
	midiParser for Lua

	MIT License
	Copyright (c) 2016 Yutaka Obuchi

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	The original version is located at:
	https://github.com/FMS-Cat/Lua_midiParser
--]]


local MThd = {77, 84, 104, 100}
local MTrk = {77, 84, 114, 107}

local function Parser(filepath)
	local result = {}

	------------------
	-- Prepare file --
	------------------

	if not filepath then
		error("Path is nil")
	end

	local midi do
		local file = io.open(filepath, "rb")
		--[[if not file then
			error("Not found: " .. filepath)
		end--]]
		if not file then
			midi = minetest.decode_base64(filepath)
			--[[local newfile = io.open(minetest.get_modpath("midi").."/midi/temp.mid", "w+")
			newfile:write(midi)
			newfile:close()--]]
			if not midi then return end
		else
			midi = file:read("*all")
			file:close()
		end
		midi:gsub("\r\n", "\n")
	end

	--------------------
	-- Some functions --
	--------------------

	local function byteArray(start, length)
		local tbl = {}
		for i = 1, length do
			tbl[i] = midi:byte(i + start - 1)
		end
		return tbl
	end

	local function bytesToNumber(start, length)
		local n = 0
		for i = 1, length do
			assert(midi:byte(i + start - 1), i + start - 1)
			n = n + midi:byte(i + start - 1) * math.pow(256, length - i)
		end
		return n
	end

	-- Variable-length quantity
	local function vlq(start)
		local n    = 0
		local head = 0
		local byte = 0

		repeat
			byte = midi:byte(start + head)
			n = n * 128 + (byte - math.floor(byte / 128) * 128)
			head = head + 1
		until math.floor(byte / 128) ~= 1

		return n, head
	end

	local function isSameTable(a, b)
		for i, v in ipairs(a) do
			if v ~= b[i] then
				return false
			end
		end

		for i, v in ipairs(b) do
			if v ~= a[i] then
				return false
			end
		end

		return true
	end

	------------------
	-- Check format --
	------------------

	local head = 1

	do -- Check "MThd"
		local MThd_LENGTH = 4

		assert(isSameTable(byteArray(head, MThd_LENGTH), MThd),
			"Input file is not midi")

		head = head + MThd_LENGTH
	end

	do -- Header chunk length
		local HEADER_LEN_LENGTH = 4

		local header_length = bytesToNumber(head, HEADER_LEN_LENGTH)
		result.header_length = header_length

		head = head + HEADER_LEN_LENGTH
	end

	do -- Check midi format
		local FORMAT_LENGTH = 2

		local format = bytesToNumber(head, FORMAT_LENGTH)
		result.format = format
		assert((format == 0 or format == 1),
			"Not supported format " .. format .. " of midi")

		head = head + FORMAT_LENGTH
	end

	do -- Track count
		local TRACK_COUNT_LENGTH = 2

		local track_count = bytesToNumber(head, TRACK_COUNT_LENGTH)
		result.track_count = track_count

		head = head + TRACK_COUNT_LENGTH
	end

	do -- Timebase
		local TIMEBASE_LENGTH = 2

		local timebase = bytesToNumber(head, TIMEBASE_LENGTH)
		result.timebase = timebase

		head = head + TIMEBASE_LENGTH
	end

	------------------------
	-- Fight against midi --
	------------------------

	result.tracks = {}

	while (#midi > head) do
		local is_MTrk = (function() -- Check MTrk
			local MTrk_LENGTH = 4

			local is_MTrk = isSameTable(byteArray(head, MTrk_LENGTH), MTrk)
			head = head + MTrk_LENGTH

			return is_MTrk
		end)()

		local chunk_length = (function() -- Chunk length
			local CHUNK_LEN_LENGTH = 4

			local chunk_length = bytesToNumber(head, CHUNK_LEN_LENGTH)
			head = head + CHUNK_LEN_LENGTH

			return chunk_length
		end)()

		if not is_MTrk then
			-- Skip unknown chunk
			head = head + chunk_length
		else
			local track = {messages = {}}
			table.insert(result.tracks, track)

			local status = 0

			local chunk_start = head
			while (chunk_start + chunk_length) > head do

				local deltaTime, deltaHead = vlq(head)
				head = head + deltaHead

				local tempStatus = bytesToNumber(head, 1)
				if math.floor(tempStatus / 128) == 1 then -- event, running status
					head   = head + 1
					status = tempStatus
				end

				local event = math.floor(status / 16)
				local channel = status - event * 16

				if event == 8 then -- Note off

					local data = byteArray(head, 2)
					head = head + 2

					table.insert(track.messages, {
						type     = "off",
						time     = deltaTime,
						channel  = channel,
						number   = data[1],
						velocity = data[2]
					})

				elseif event == 9 then -- Note on

					local data = byteArray(head, 2)
					head = head + 2

					table.insert(track.messages, {
						type     = "on",
						time     = deltaTime,
						channel  = channel,
						number   = data[1],
						velocity = data[2]
					})

				elseif event == 10 then -- Polyphonic keypressure

					local data = byteArray(head, 2)
					head = head + 2

					table.insert(track.messages, {
						time = deltaTime
					})

				elseif event == 11 then -- Control change

					local data = byteArray(head, 2)
					head = head + 2

					table.insert(track.messages, {
						time = deltaTime
					})

				elseif event == 12 then -- Program change

					local data = byteArray(head, 1)
					head = head + 1

					table.insert(track.messages, {
						type    = "program_change",
						time    = deltaTime,
						channel = channel,
						program = tonumber(data[1])
					})

				elseif event == 13 then -- Channel pressure

					local data = byteArray(head, 1)
					head = head + 1

					table.insert(track.messages, {
						time = deltaTime
					})

				elseif event == 14 then -- Pitch bend

					local data = byteArray(head, 2)
					head = head + 2

					table.insert(track.messages, {
						time = deltaTime
					})

				elseif status == 255 then -- Meta event

					local metaType = bytesToNumber(head, 1)
					head = head + 1

					local metaLength, metaHead = vlq(head)

					--[[if metaType == 0 then -- sequence number
					elseif metaType == 1 then -- text
					elseif metaType == 2 then -- licence
					else]]if metaType == 3 then -- track name

						head = head + metaHead
						track.name = midi:sub(head, head + metaLength - 1)
						head = head + metaLength

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Track Name",
							text = track.name
						})

					elseif metaType == 4 then -- instrument name

						head = head + metaHead
						track.instrument = midi:sub(head, head + metaLength - 1)
						head = head + metaLength

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Instrument Name",
							text = track.instrument
						} )

					elseif metaType == 5 then -- lyric
						head = head + metaHead
						track.lyric = string.sub( midi, head, head + metaLength - 1 )
						head = head + metaLength

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Lyric",
							text = track.lyric
						} )

					--elseif metaType == 6 then -- marker
					--elseif metaType == 7 then -- queue point
					elseif metaType == 8 then -- program name or sound name
						head = head + metaHead
						local v = string.sub( midi, head, head + metaLength - 1 )
						head = head + metaLength

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Meta8",
							text = v
						} )
 
					elseif metaType == 9 then -- device name or spundfont name
						head = head + metaHead
						local v = string.sub( midi, head, head + metaLength - 1 )
						head = head + metaLength

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Meta9",
							text = v
						} )
					--elseif metaType == 32 then -- midi channel prefix
					--elseif metaType == 33 then -- select port
					elseif metaType == 47 then -- end of track
						head = head + 1

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "End of Track"
						} )

						break

					elseif metaType == 81 then -- tempo
						head = head + 1

						local micros = bytesToNumber( head, 3 )
						head = head + 3

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Set Tempo",
							tempo = micros
						} )

					--elseif metaType == 84 then -- SMPTE offset
					elseif metaType == 88 then -- time signature
						head = head + 1

						local sig = byteArray( head, 4 )
						head = head + 4

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Time Signature",
							signature = sig
						} )

					elseif metaType == 89 then -- key signature
	
						head = head + 1
						local sig = byteArray(head, 2)
						head = head + 2

						table.insert( track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Key Signature",
							signature = sig
						} )

					--elseif metaType == 127 then -- sequencer specific event
					else -- comment

						head = head + metaHead
						local text = midi:sub(head, head + metaLength - 1)
						head = head + metaLength

						table.insert(track.messages, {
							time = deltaTime,
							type = "meta",
							meta = "Unknown Text: ",
							text = text
						})

					end
				end
			end

		end

	end

	return result
end

return Parser
