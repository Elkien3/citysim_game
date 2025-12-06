midi = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

----------------------------------------
-- Registration function
----------------------------------------

midi.registered_instruments = {}

function midi.register_instrument(program_number, def)
	midi.registered_instruments[program_number] = {
		description = def.description,
		get_sounds  = def.get_sounds,
	}
end

----------------------------------------
-- Helper
----------------------------------------

function midi.get_scale(note_number)
	local scales = {
		"C-1", "C#-1", "D-1", "D#-1", "E-1", "F-1", "F#-1", "G-1", "G#-1", "A-1", "A#-1", "B-1",
		"C0",  "C#0",  "D0",  "D#0",  "E0",  "F0",  "F#0",  "G0",  "G#0",  "A0",  "A#0",  "B0",
		"C1",  "C#1",  "D1",  "D#1",  "E1",  "F1",  "F#1",  "G1",  "G#1",  "A1",  "A#1",  "B1",
		"C2",  "C#2",  "D2",  "D#2",  "E2",  "F2",  "F#2",  "G2",  "G#2",  "A2",  "A#2",  "B2",
		"C3",  "C#3",  "D3",  "D#3",  "E3",  "F3",  "F#3",  "G3",  "G#3",  "A3",  "A#3",  "B3",
		"C4",  "C#4",  "D4",  "D#4",  "E4",  "F4",  "F#4",  "G4",  "G#4",  "A4",  "A#4",  "B4",
		"C5",  "C#5",  "D5",  "D#5",  "E5",  "F5",  "F#5",  "G5",  "G#5",  "A5",  "A#5",  "B5",
		"C6",  "C#6",  "D6",  "D#6",  "E6",  "F6",  "F#6",  "G6",  "G#6",  "A6",  "A#6",  "B6",
		"C7",  "C#7",  "D7",  "D#7",  "E7",  "F7",  "F#7",  "G7",  "G#7",  "A7",  "A#7",  "B7",
		"C8",  "C#8",  "D8",  "D#8",  "E8",  "F8",  "F#8",  "G8",  "G#8",  "A8",  "A#8",  "B8",
		"C9",  "C#9",  "D9",  "D#9",  "E9",  "F9",  "F#9",  "G9",  "G#9",  "A9",  "A#9",  "B9"
	}

	local scale = scales[note_number + 1] -- Note number starts at 0, but Lua table index starts at 1.
	return scale or "None"
end

----------------------------------------
-- Loading function
----------------------------------------

-- Merge tracks to single track
local function merge_tracks(tracks)
	local track_merged, timings = {}, {}

	for _, track in ipairs(tracks) do
		local time    = 0 -- Current time
		local program = 1 -- Instrument number

		for _, message in ipairs(track.messages) do
			time = time + message.time

			-- Initialize notes
			if not track_merged[time] then
				track_merged[time] = {
					notes        = {},
					tempo_change = nil -- For 'time_to_seconds' function
				}
				table.insert(timings, time)
			end

			if (message.type == "on") or (message.type == "off") then -- Note on/off
				local note = {
					type     = message.type,
					number   = message.number,
					velocity = message.velocity or 80,
					program  = program
				}
				table.insert(track_merged[time].notes, note)
			elseif (message.type == "meta") and message.tempo then -- Change tempo
				track_merged[time].tempo_change = message.tempo
			elseif (message.type == "program_change") then -- Change program(instrument)
				program = message.program
			end
		end
	end

	table.sort(timings)

	return track_merged, timings
end

-- Convert track to table that has seconds as key
local function time_to_seconds(track, timings, timebase)
	local track_converted = {}

	local tempo   = 0.5 -- Dummy
	local seconds = 0

	for i, time in ipairs(timings) do
		local data = track[time]

		-- Change tempo
		if data.tempo_change then
			tempo = (data.tempo_change / 1000000) -- Micro seconds to seconds
		end

		-- Convert time to seconds
		local difftime = timings[i] - (timings[i - 1] or 0)
		seconds = seconds + (difftime / timebase * tempo)

		for _, note in ipairs(data.notes) do
			if (note.type == "on") or (note.type == "off") then
				if not track_converted[seconds] then
					track_converted[seconds] = {}
				end
				table.insert(track_converted[seconds], note)
			end
		end
	end

	return track_converted
end

local parser = dofile(modpath .. "/lib/parser.lua")
function midi.load_midi(midi_path)
	local midi_parsed = parser(midi_path)

	local tracks = midi_parsed.tracks
	local track_merged, timings = merge_tracks(tracks)
	local track = time_to_seconds(track_merged, timings, midi_parsed.timebase)

	return track
end

----------------------------------------
-- Playing function
----------------------------------------

midi.playingsongs = {}

function midi.play_midi(name, track, delay, index)
	local lastnotetime = 0
	for seconds, notes in pairs(track) do
		if seconds > lastnotetime then lastnotetime = seconds end
	end
	local tbl = {name = name, track = track, playhead = -delay, handles = {}, lastnotetime = lastnotetime, playing = true}
	if index then
		midi.stop_midi(index)
		midi.playingsongs[index] = tbl
	else
		table.insert(midi.playingsongs, tbl)
	end
end

function midi.stop_midi(index, removetbl)
	if not index then return end
	local songtbl = midi.playingsongs[index]
	if not songtbl then return end
	for i1, handletbl in pairs(songtbl.handles) do
		for i2, handle in pairs(handletbl) do
			minetest.sound_fade(handle, 6, 0)
		end
	end
	if removetbl then
		midi.playingsongs[index] = nil
	end
end

minetest.register_globalstep(function(dtime)
	for i, tbl in pairs(midi.playingsongs) do
		if tbl.playing then
			local handles = tbl.handles
			local track = tbl.track
			local name = tbl.name
			local function note_off(note)
				local fade = [[
					if handles[%d] then
						for i = 1, #handles[%d] do
							fade(handles[%d][i], %f, 0)
						end
						handles[%d] = nil
					end
				]]
				local step = ((note.velocity ~= 0 and note.velocity or 50) / -10)
				return fade:format(note.number, note.number, note.number, 15, note.number)--step value was weird so did a global number
			end
			local function note_on(note, handles)
				local create_handle_list = [[
					if not handles[%d] then
						handles[%d] = {}
					end
				]]

				local play
				if minetest.get_player_by_name(name) then
					play = [[
						handles[%d][#handles[%d] + 1] = play("%s", {
							gain = %f,
							pitch = %f,
							to_player = "%s",
						})
					]]
				else
					play = [[
						handles[%d][#handles[%d] + 1] = play("%s", {
							gain = %f,
							pitch = %f,
							pos = %s
						})
					]]
				end

				-- Get sounds
				local instrument = midi.registered_instruments[note.program]
				if not instrument then
					return ""
				end

				local sounds = instrument.get_sounds(table.copy(note))
				if (#sounds == 0) then
					return ""
				end

				local func = ""
				for _, sound in ipairs(sounds) do
					if (sound.gain > 0) and (sound.pitch > 0) then
						func = func .. " " .. play:format(note.number, note.number, sound.name, sound.gain, sound.pitch, name)
					end
				end

				local is_func_empty = (func:gsub(" ", "") == "")
				if is_func_empty then
					return ""
				end

				return create_handle_list:format(note.number, note.number) .. func
			end
			local function note_release(note)
				local play
				if minetest.get_player_by_name(name) then
					play = [[
						play("%s", {
							gain = %f,
							pitch = %f,
							to_player = "%s"
						})
					]]
				else
					play = [[
						play("%s", {
							gain = %f,
							pitch = %f,
							pos = %s
						})
					]]
				end

				-- Get sounds
				local instrument = midi.registered_instruments[note.program]
				if not instrument then
					return ""
				end

				local sounds = instrument.get_sounds(table.copy(note))
				if (#sounds == 0) then
					return ""
				end

				local func = ""
				for _, sound in ipairs(sounds) do
					if (sound.gain > 0) and (sound.pitch > 0) then
						func = func .. " " .. play:format(sound.name, sound.gain, sound.pitch, name)
					end
				end

				return func
			end
			
			local newplayhead = tbl.playhead + dtime
			for seconds, notes in pairs(track) do
				if seconds > tbl.playhead and seconds <= newplayhead then
					local function_string = ""

					for _, note in ipairs(notes) do
						if (note.velocity == 0) then
							note.type = "off"
						end

						if (note.type == "on") then
							function_string = function_string .. " " .. note_on(note, handles)
						elseif (note.type == "off") then
							function_string = note_off(note) .. " " .. function_string
							function_string = function_string .. " " .. note_release(note)
						end
					end

					local is_func_empty = (function_string:gsub(" ", "") == "")
					if not is_func_empty then
						local func = [[
							return function(handles, play, fade)
								%s
							end
						]]
						--minetest.after(seconds-tbl.playhead, loadstring(func:format(function_string))(), handles, minetest.sound_play, minetest.sound_fade)
						loadstring(func:format(function_string))()(handles, minetest.sound_play, minetest.sound_fade)
					end
				end
			end
			tbl.playhead = newplayhead
			if newplayhead > tbl.lastnotetime then--could set this back to 0 or do some other sort of callback if we wanted to repeat or play another song
				midi.playingsongs[i] = nil
			end
		end
	end
end)

----------------------------------------
-- Chatcommand
----------------------------------------

minetest.register_chatcommand("midi", {
	description = "Play midi",
	params = "<midiname> [delay]",
	func = function(name, param)
		local params = param:split(" ")

		local midi_name = params[1]
		if not midi_name then
			return false, "midiname required"
		end

		local flag, ret = pcall(function()
			local midi_path = (modpath .. "/midi/" .. midi_name)
			return midi.load_midi(midi_path)
			--local flat, ret = midi.load_midi(midi_path)
		end)

		if not flag then
			return false, ret
		end

		local delay = tonumber(params[2]) or 1
		midi.play_midi(name, ret, delay)
	end
})
minetest.register_chatcommand("midistopall", {
	description = "Stop all midi songs",
	params = "<midiname> [delay]",
	privs = {server = true},
	func = function(name, param)
		for i, tbl in pairs(midi.playingsongs) do
			midi.stop_midi(i, true)
		end
		midi.playingsongs = {}
	end
})

minetest.register_chatcommand("midiconvert", {
	description = "Convert midi file to Base64 string.",
	params = "<midiname>",
	privs = {server = true},
	func = function(name, param)
		local midi_name = param
		if not midi_name then
			return false, "midiname required"
		end
		local midi_path = (modpath .. "/midi/" .. midi_name)

		local file = io.open(midi_path, "rb")
		if not file then return false, "Could not find file '"..param.."'" end
		local midi = file:read("*all")
		file:close()
		if not midi then return false, "Could not parse file '"..param.."'" end
		midi = minetest.encode_base64(midi)
		--[[local file = io.open(modpath .. "/midi/" .. "temp.mid", "w+")
		file:write(midi)
		file:close()--]]
		local form = "size[5,2]field[1,1;4,1;field;Copy/Paste from here;"..midi.."]"
		minetest.show_formspec(name, "midi:convert", form)
		return true, "Converted Succesfully"
	end
})